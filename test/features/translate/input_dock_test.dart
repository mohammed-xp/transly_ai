import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/core/theme/app_theme.dart';
import 'package:transly_ai/features/translate/presentation/widgets/input_dock.dart';
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
  final en = lookupAppLocalizations(const Locale('en'));

  group('InputDock', () {
    testWidgets('renders the three localized mode labels', (tester) async {
      await tester.pumpWidget(
        _wrap(
          InputDock(
            currentMode: TranslateInputMode.keyboard,
            onModeSelected: (_) {},
          ),
        ),
      );

      expect(find.text(en.translateDockKeyboard), findsOneWidget);
      expect(find.text(en.translateDockVoice), findsOneWidget);
      expect(find.text(en.translateDockCamera), findsOneWidget);
    });

    testWidgets('the active tab is inert; the others are tappable', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          InputDock(
            currentMode: TranslateInputMode.keyboard,
            onModeSelected: (_) {},
          ),
        ),
      );

      final inkWells = tester.widgetList<InkWell>(find.byType(InkWell));
      expect(inkWells.length, 3);
      expect(inkWells.elementAt(0).onTap, isNull); // keyboard — active
      expect(inkWells.elementAt(1).onTap, isNotNull); // voice
      expect(inkWells.elementAt(2).onTap, isNotNull); // camera
    });

    testWidgets('tapping Voice reports the new mode exactly once', (
      tester,
    ) async {
      final selected = <TranslateInputMode>[];
      await tester.pumpWidget(
        _wrap(
          InputDock(
            currentMode: TranslateInputMode.keyboard,
            onModeSelected: selected.add,
          ),
        ),
      );

      await tester.tap(find.text(en.translateDockVoice));
      await tester.pump();

      expect(selected, [TranslateInputMode.voice]);
    });

    testWidgets('tapping the already-active tab does nothing', (
      tester,
    ) async {
      final selected = <TranslateInputMode>[];
      await tester.pumpWidget(
        _wrap(
          InputDock(
            currentMode: TranslateInputMode.camera,
            onModeSelected: selected.add,
          ),
        ),
      );

      await tester.tap(find.text(en.translateDockCamera));
      await tester.pump();

      expect(selected, isEmpty);
    });

    testWidgets('the active tab is highlighted in coral, others in muted', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          InputDock(
            currentMode: TranslateInputMode.camera,
            onModeSelected: (_) {},
          ),
        ),
      );

      final icons = tester.widgetList<Icon>(find.byType(Icon)).toList();
      expect(icons[0].color, AppPalette.light.textMuted); // keyboard
      expect(icons[1].color, AppPalette.light.textMuted); // voice
      expect(icons[2].color, AppPalette.light.coral); // camera — active
    });
  });
}
