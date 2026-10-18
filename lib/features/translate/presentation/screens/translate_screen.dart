import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/l10n/failure_message.dart';
import '../../../../core/l10n/language_label.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_icon_source.dart';
import '../../../../core/widgets/toast/app_toast.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../language_picker/presentation/cubit/auto_download_notice_cubit.dart';
import '../../../language_picker/presentation/widgets/auto_download_notice.dart';
import '../../domain/entities/translation_tone.dart';
import '../cubit/translate_cubit.dart';
import '../cubit/translate_state.dart';
import '../widgets/source_card.dart';
import '../widgets/tone_selector.dart';
import '../widgets/translate_busy_note.dart';
import '../widgets/translation_output_card.dart';

class TranslateScreen extends StatelessWidget {
  const TranslateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<AutoDownloadNoticeCubit>(),
      child: BlocListener<TranslateCubit, TranslateState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            (previous.status is TranslationError ||
                current.status is TranslationError),
        listener: _onErrorChanged,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.spaceL,
            AppDimens.spaceL - 2,
            AppDimens.spaceL,
            0,
          ),
          children: const [
            AutoDownloadNotice(),
            _SourceSection(),
            SizedBox(height: AppDimens.spaceM),
            _OutputSection(),
            _BusyNoteSection(),
            SizedBox(height: AppDimens.spaceM),
            _ToneSection(),
          ],
        ),
      ),
    );
  }

  /// Error toast with Retry while a translation is failed; cleared as soon as
  /// the status leaves the error (new input, retry, language change).
  void _onErrorChanged(BuildContext context, TranslateState state) {
    final status = state.status;
    if (status is! TranslationError) {
      AppToast.hide(context);
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    AppToast.show(
      context,
      message: l10n.translateErrorTitle,
      subtitle: failureMessage(context, status.failure),
      type: AppToastType.error,
      actionLabel: l10n.translateRetry,
      onAction: context.read<TranslateCubit>().translateNow,
    );
  }
}

class _SourceSection extends StatelessWidget {
  const _SourceSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocSelector<
      TranslateCubit,
      TranslateState,
      (String, LanguageEntity)
    >(
      selector: (state) => (state.sourceText, state.from),
      builder: (context, data) {
        final cubit = context.read<TranslateCubit>();
        final text = data.$1;
        final from = data.$2;
        return SourceCard(
          language: languageLabel(context, from),
          text: text,
          hintText: l10n.translateSourceHint,
          textDirection: from.isRtl ? TextDirection.rtl : TextDirection.ltr,
          onChanged: cubit.sourceTextChanged,
          onSubmitted: cubit.translateNow,
          onSpeak: text.trim().isEmpty ? null : cubit.speakSource,
        );
      },
    );
  }
}

/// Selects the output text, target language, and async status.
class _OutputSection extends StatelessWidget {
  const _OutputSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocSelector<
      TranslateCubit,
      TranslateState,
      (String, LanguageEntity, TranslationStatus)
    >(
      selector: (state) => (state.translatedText, state.to, state.status),
      builder: (context, data) {
        final cubit = context.read<TranslateCubit>();
        final status = data.$3;
        final (busyLabel, errorMessage) = switch (status) {
          TranslationInProgress() => (l10n.translateInProgress, null),
          TranslationError(:final failure) => (
            null,
            failureMessage(context, failure),
          ),
          TranslationIdle() || TranslationDone() => (null, null),
        };
        final output = data.$1;
        final to = data.$2;
        final isBusy = busyLabel != null;
        return TranslationOutputCard(
          language: languageLabel(context, to),
          text: output,
          textDirection: to.isRtl ? TextDirection.rtl : TextDirection.ltr,
          busyLabel: busyLabel,
          errorMessage: errorMessage,
          onCopy: (output.isEmpty || isBusy)
              ? null
              : () async {
                  await Clipboard.setData(ClipboardData(text: output));
                  if (!context.mounted) return;
                  AppToast.show(
                    context,
                    message: l10n.translateCopied,
                    icon: const SvgIconSource(AppIcons.copyToast),
                  );
                },
          // Matches TranslateCubit.speakOutput's own guard — a whitespace-only
          // output must not render an enabled button that does nothing.
          onSpeak: (output.trim().isEmpty || isBusy) ? null : cubit.speakOutput,
        );
      },
    );
  }
}

class _BusyNoteSection extends StatelessWidget {
  const _BusyNoteSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocSelector<TranslateCubit, TranslateState, TranslationStatus>(
      selector: (state) => state.status,
      builder: (context, status) {
        final message = switch (status) {
          TranslationInProgress() => l10n.translateAiAnalyzing,
          TranslationIdle() || TranslationDone() || TranslationError() => null,
        };
        if (message == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: AppDimens.spaceM),
          child: TranslateBusyNote(message: message),
        );
      },
    );
  }
}

/// Selects the tones, current tone and enabled flag. Hidden until the tones
/// have been loaded once.
class _ToneSection extends StatelessWidget {
  const _ToneSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      TranslateCubit,
      TranslateState,
      (List<TranslationTone>, TranslationTone?, bool)
    >(
      selector: (state) =>
          (state.tones, state.tone, state.isToneEnabled && !state.isBusy),
      builder: (context, data) {
        final selected = data.$2;
        if (data.$1.isEmpty || selected == null) return const SizedBox.shrink();
        return ToneSelector(
          tones: data.$1,
          selected: selected,
          enabled: data.$3,
          onSelected: context.read<TranslateCubit>().toneChanged,
        );
      },
    );
  }
}
