import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../widgets/input_dock.dart';
import '../widgets/language_bar.dart';
import '../widgets/source_card.dart';
import '../widgets/tone_selector.dart';
import '../widgets/translate_header.dart';
import '../widgets/translation_output_card.dart';

/// Main translate screen (design `02 · Translate`, light + dark). A fixed header
/// and language bar, a scrollable middle (source + AI output + tone), and a
/// fixed bottom input dock.
///
/// Presentation-only — no cubit yet; the sample content below is placeholder
/// until translation state exists.
class TranslateScreen extends StatelessWidget {
  const TranslateScreen({super.key});

  // TODO(translate): replace with cubit state once translation logic exists.
  static const String _fromLanguage = 'English';
  static const String _toLanguage = 'العربية';
  static const String _sourceText =
      'Could you tell me how to get to the central train station?';
  static const String _outputText =
      'هل يمكنك أن تدلّني على الطريق إلى محطة القطار المركزية؟';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TranslateHeader(isDark: isDark),
            LanguageBar(
              isDark: isDark,
              fromLanguage: _fromLanguage,
              toLanguage: _toLanguage,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.spaceL,
                  AppDimens.spaceL - 2,
                  AppDimens.spaceL,
                  0,
                ),
                children: [
                  SourceCard(
                    isDark: isDark,
                    language: _fromLanguage,
                    text: _sourceText,
                  ),
                  const SizedBox(height: AppDimens.spaceM),
                  TranslationOutputCard(
                    isDark: isDark,
                    language: _toLanguage,
                    text: _outputText,
                  ),
                  const SizedBox(height: AppDimens.spaceM),
                  ToneSelector(isDark: isDark),
                ],
              ),
            ),
            InputDock(isDark: isDark),
          ],
        ),
      ),
    );
  }
}
