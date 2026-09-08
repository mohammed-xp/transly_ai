import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/theme/app_theme.dart';
import 'package:transly_ai/features/translate/presentation/widgets/language_bar.dart';
import 'package:transly_ai/features/translate/presentation/widgets/translate_progress_bar.dart';
import 'package:transly_ai/features/translate/presentation/widgets/translation_skeleton.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('LanguageBar', () {
    testWidgets('shows the progress bar only while busy', (tester) async {
      await tester.pumpWidget(
        _wrap(
          LanguageBar(
            fromLanguage: 'English',
            toLanguage: 'العربية',
            onSwap: () {},
            isBusy: false,
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(TranslateProgressBar), findsNothing);

      await tester.pumpWidget(
        _wrap(
          LanguageBar(
            fromLanguage: 'English',
            toLanguage: 'العربية',
            onSwap: () {},
            isBusy: true,
          ),
        ),
      );
      // TranslateProgressBar animates forever — one frame is enough to assert
      // it mounted; pumpAndSettle would never converge.
      await tester.pump();
      expect(find.byType(TranslateProgressBar), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 600));
    });
  });

  group('TranslationSkeleton', () {
    testWidgets(
      'renders three shimmering lines and survives mid-animation pumps',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const TranslationSkeleton(textDirection: TextDirection.rtl)),
        );
        await tester.pump();

        // One FractionallySizedBox per shimmer line (widths 100% / 88% / 56%).
        expect(find.byType(FractionallySizedBox), findsNWidgets(3));

        await tester.pump(const Duration(milliseconds: 700));
        await tester.pump(const Duration(milliseconds: 700));
      },
    );
  });
}
