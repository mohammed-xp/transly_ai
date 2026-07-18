import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    // While the keyboard is open it takes the dock's place at the bottom; the
    // dock reappears when the keyboard closes.
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TranslateHeader(isDark: isDark),
            _LanguageBarSection(isDark: isDark),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppDimens.spaceL,
                  AppDimens.spaceL - 2,
                  AppDimens.spaceL,
                  keyboardOpen ? AppDimens.spaceL : 0,
                ),
                children: [
                  _SourceSection(isDark: isDark),
                  const SizedBox(height: AppDimens.spaceM),
                  _OutputSection(isDark: isDark),
                  const SizedBox(height: AppDimens.spaceM),
                  _ToneSection(isDark: isDark),
                ],
              ),
            ),
            if (!keyboardOpen) InputDock(isDark: isDark),
          ],
        ),
      ),
    );
  }
}

/// Selects only the language pair — rebuilds on swap, not on every keystroke.
class _LanguageBarSection extends StatelessWidget {
  const _LanguageBarSection({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TranslateCubit, TranslateState, (Language, Language)>(
      selector: (state) => (state.from, state.to),
      builder: (context, pair) {
        return LanguageBar(
          isDark: isDark,
          fromLanguage: languageLabel(context, pair.$1),
          toLanguage: languageLabel(context, pair.$2),
          onSwap: context.read<TranslateCubit>().swapLanguages,
        );
      },
    );
  }
}

/// Selects the source-side fields (text + from language) for the editable card.
class _SourceSection extends StatelessWidget {
  const _SourceSection({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocSelector<TranslateCubit, TranslateState, (String, Language)>(
      selector: (state) => (state.sourceText, state.from),
      builder: (context, data) {
        final cubit = context.read<TranslateCubit>();
        return SourceCard(
          isDark: isDark,
          language: languageLabel(context, data.$2),
          text: data.$1,
          hintText: l10n.translateSourceHint,
          textDirection:
              data.$2.isRtl ? TextDirection.rtl : TextDirection.ltr,
          onChanged: cubit.sourceTextChanged,
          onSubmitted: cubit.translateNow,
        );
      },
    );
  }
}

/// Selects the output text, target language, and async status.
class _OutputSection extends StatelessWidget {
  const _OutputSection({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocSelector<TranslateCubit, TranslateState,
        (String, Language, TranslationStatus)>(
      selector: (state) => (state.translatedText, state.to, state.status),
      builder: (context, data) {
        final status = data.$3;
        final (statusMessage, isBusy) = switch (status) {
          TranslationDownloadingModel() => (l10n.translateDownloadingModel, true),
          TranslationInProgress() => (null, true),
          TranslationError(:final failure) => (
              failureMessage(context, failure),
              false,
            ),
          TranslationIdle() || TranslationDone() => (null, false),
        };
        final output = data.$1;
        return TranslationOutputCard(
          isDark: isDark,
          language: languageLabel(context, data.$2),
          text: output,
          textDirection: data.$2.isRtl ? TextDirection.rtl : TextDirection.ltr,
          statusMessage: statusMessage,
          isBusy: isBusy,
          // No in-app confirmation — the OS shows its own copy feedback.
          onCopy: output.isEmpty
              ? null
              : () => Clipboard.setData(ClipboardData(text: output)),
        );
      },
    );
  }
}

/// Selects the tone + enabled flag.
class _ToneSection extends StatelessWidget {
  const _ToneSection({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TranslateCubit, TranslateState, (TranslationTone, bool)>(
      selector: (state) => (state.tone, state.isToneEnabled),
      builder: (context, data) {
        return ToneSelector(
          isDark: isDark,
          selected: data.$1,
          enabled: data.$2,
          onSelected: context.read<TranslateCubit>().toneChanged,
        );
      },
    );
  }
}
