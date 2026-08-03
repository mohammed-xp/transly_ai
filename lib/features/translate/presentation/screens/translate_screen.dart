import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/language.dart';
import '../../domain/entities/translation_tone.dart';
import '../cubit/translate_cubit.dart';
import '../cubit/translate_state.dart';
import '../utils/translate_l10n.dart';
import '../widgets/input_dock.dart';
import '../widgets/language_bar.dart';
import '../widgets/source_card.dart';
import '../widgets/tone_selector.dart';
import '../widgets/translate_busy_note.dart';
import '../widgets/translate_header.dart';
import '../widgets/translation_output_card.dart';

/// Main translate screen (design `02 · Translate`, light + dark). A fixed header
/// and language bar, a scrollable middle (source + AI output + tone), and a
/// fixed bottom input dock — all driven by [TranslateCubit].
class TranslateScreen extends StatelessWidget {
  const TranslateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TranslateCubit>(),
      child: const _TranslateView(),
    );
  }
}

class _TranslateView extends StatelessWidget {
  const _TranslateView();

  @override
  Widget build(BuildContext context) {
    // While the keyboard is open it takes the dock's place at the bottom; the
    // dock reappears when the keyboard closes.
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const TranslateHeader(),
            const _LanguageBarSection(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppDimens.spaceL,
                  AppDimens.spaceL - 2,
                  AppDimens.spaceL,
                  keyboardOpen ? AppDimens.spaceL : 0,
                ),
                children: [
                  const _SourceSection(),
                  const SizedBox(height: AppDimens.spaceM),
                  const _OutputSection(),
                  const _BusyNoteSection(),
                  const SizedBox(height: AppDimens.spaceM),
                  const _ToneSection(),
                ],
              ),
            ),
            if (!keyboardOpen) const InputDock(),
          ],
        ),
      ),
    );
  }
}

/// Selects only the language pair — rebuilds on swap, not on every keystroke.
class _LanguageBarSection extends StatelessWidget {
  const _LanguageBarSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TranslateCubit, TranslateState,
        (Language, Language, bool)>(
      selector: (state) => (state.from, state.to, state.isBusy),
      builder: (context, data) {
        return LanguageBar(
          fromLanguage: languageLabel(context, data.$1),
          toLanguage: languageLabel(context, data.$2),
          onSwap: context.read<TranslateCubit>().swapLanguages,
          isBusy: data.$3,
        );
      },
    );
  }
}

/// Selects the source-side fields (text + from language) for the editable card.
class _SourceSection extends StatelessWidget {
  const _SourceSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocSelector<TranslateCubit, TranslateState, (String, Language)>(
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
    return BlocSelector<TranslateCubit, TranslateState,
        (String, Language, TranslationStatus)>(
      selector: (state) => (state.translatedText, state.to, state.status),
      builder: (context, data) {
        final cubit = context.read<TranslateCubit>();
        final status = data.$3;
        final (busyLabel, errorMessage) = switch (status) {
          TranslationDownloadingModel() ||
          TranslationInProgress() =>
            (l10n.translateInProgress, null),
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

/// Shows the AI-analyzing / model-download caption under the output card
/// while [TranslateState.isBusy] — hidden the rest of the time.
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
    return BlocSelector<TranslateCubit, TranslateState, (TranslationTone, bool)>(
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
