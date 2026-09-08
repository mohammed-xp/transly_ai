import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/theme/app_theme.dart';
import 'package:transly_ai/features/translate/presentation/widgets/speaker_button.dart';
import 'package:transly_ai/features/translate/presentation/widgets/translating_dots.dart';
import 'package:transly_ai/features/translate/presentation/widgets/translation_output_card.dart';
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
  group('TranslationOutputCard', () {
    // busyLabel/errorMessage/onCopy/onSpeak are all required, non-nullable
    // params — every case below sets each explicitly rather than relying on
    // a shared default, so a future required-param addition fails loudly here
    // instead of silently passing null.

    testWidgets('idle with text shows the output and enables actions', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          TranslationOutputCard(
            language: 'العربية',
            text: 'مرحبا',
            textDirection: TextDirection.rtl,
            busyLabel: null,
            errorMessage: null,
            onCopy: () {},
            onSpeak: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('مرحبا'), findsOneWidget);
      expect(find.byType(TranslationSkeleton), findsNothing);
      expect(find.byType(SpeakerButton), findsOneWidget);
      expect(find.byType(TranslatingDots), findsNothing);

      final speaker = tester.widget<SpeakerButton>(find.byType(SpeakerButton));
      expect(speaker.onTap, isNotNull);
    });

    testWidgets('busy hides the stale text and shows the skeleton + dots', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          TranslationOutputCard(
            language: 'العربية',
            text: 'stale previous output',
            textDirection: TextDirection.rtl,
            busyLabel: 'Translating',
            errorMessage: null,
            onCopy: null,
            onSpeak: null,
          ),
        ),
      );
      // Animated widgets — a single frame is enough to assert structure.
      await tester.pump();

      expect(find.text('stale previous output'), findsNothing);
      expect(find.byType(TranslationSkeleton), findsOneWidget);
      expect(find.text('Translating'), findsOneWidget);
      expect(find.byType(TranslatingDots), findsOneWidget);
      expect(find.byType(SpeakerButton), findsNothing);

      // Copy/save actions are disabled while busy.
      final buttons = tester.widgetList<InkWell>(find.byType(InkWell));
      expect(buttons.every((b) => b.onTap == null), isTrue);

      await tester.pump(const Duration(milliseconds: 700));
    });

    testWidgets('error shows the message without a skeleton', (tester) async {
      await tester.pumpWidget(
        _wrap(
          TranslationOutputCard(
            language: 'العربية',
            text: '',
            textDirection: TextDirection.rtl,
            busyLabel: null,
            errorMessage: "Couldn't translate. Please try again.",
            onCopy: null,
            onSpeak: null,
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text("Couldn't translate. Please try again."),
        findsOneWidget,
      );
      expect(find.byType(TranslationSkeleton), findsNothing);
      expect(find.byType(TranslatingDots), findsNothing);
    });
  });
}
