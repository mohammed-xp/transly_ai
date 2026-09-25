import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/l10n/failure_message.dart';
import '../../../../core/l10n/language_label.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../l10n/app_localizations.dart';
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.spaceL,
        AppDimens.spaceL - 2,
        AppDimens.spaceL,
        0,
      ),
      children: [
        const _SourceSection(),
        const SizedBox(height: AppDimens.spaceM),
        const _OutputSection(),
        const _BusyNoteSection(),
        const SizedBox(height: AppDimens.spaceM),
        const _ToneSection(),
      ],
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
          TranslationDownloadingModel() ||
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
          // No in-app confirmation — the OS shows its own copy feedback.
          onCopy: (output.isEmpty || isBusy)
              ? null
              : () => Clipboard.setData(ClipboardData(text: output)),
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
          TranslationDownloadingModel() => l10n.translateDownloadingModel,
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

/// Selects the tone + enabled flag.
class _ToneSection extends StatelessWidget {
  const _ToneSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      TranslateCubit,
      TranslateState,
      (TranslationTone, bool)
    >(
      selector: (state) => (state.tone, state.isToneEnabled && !state.isBusy),
      builder: (context, data) {
        return ToneSelector(
          selected: data.$1,
          enabled: data.$2,
          onSelected: context.read<TranslateCubit>().toneChanged,
        );
      },
    );
  }
}
