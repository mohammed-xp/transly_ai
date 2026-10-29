import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/features/home/presentation/widgets/input_dock.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

void main() {
  Future<void> pumpDock(WidgetTester tester, InputDock dock) {
    return tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppPalette.light]),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Align(alignment: Alignment.bottomCenter, child: dock),
        ),
      ),
    );
  }

  testWidgets('tapping Conversation selects the voice mode', (tester) async {
    TranslateInputMode? selected;
    await pumpDock(
      tester,
      InputDock(
        currentMode: TranslateInputMode.keyboard,
        onModeSelected: (mode) => selected = mode,
      ),
    );

    await tester.tap(find.text('Conversation'));

    expect(selected, TranslateInputMode.voice);
  });

  testWidgets('a raised voice tab replaces the plain one', (tester) async {
    await pumpDock(
      tester,
      InputDock(
        currentMode: TranslateInputMode.voice,
        onModeSelected: (_) {},
        voiceTab: const SizedBox(key: Key('raised'), width: 76, height: 90),
        voiceTabRaise: 44,
      ),
    );

    expect(find.byKey(const Key('raised')), findsOneWidget);
    expect(find.text('Conversation'), findsNothing);
    expect(find.text('Translate'), findsOneWidget);
    expect(find.text('Camera'), findsOneWidget);
  });

  testWidgets('the part of the voice tab above the dock is tappable', (
    tester,
  ) async {
    var taps = 0;
    await pumpDock(
      tester,
      InputDock(
        currentMode: TranslateInputMode.voice,
        onModeSelected: (_) {},
        voiceTab: GestureDetector(
          key: const Key('raised'),
          behavior: HitTestBehavior.opaque,
          onTap: () => taps++,
          child: const SizedBox(width: 76, height: 90),
        ),
        voiceTabRaise: 44,
      ),
    );

    final top = tester.getRect(find.byKey(const Key('raised'))).topCenter;
    await tester.tapAt(top + const Offset(0, 4));

    expect(taps, 1);
  });
}
