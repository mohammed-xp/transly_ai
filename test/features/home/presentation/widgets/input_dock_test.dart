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
          body: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [dock],
          ),
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

  testWidgets('a closed voice tab leaves the plain tab tappable', (
    tester,
  ) async {
    TranslateInputMode? selected;
    await pumpDock(
      tester,
      InputDock(
        currentMode: TranslateInputMode.keyboard,
        onModeSelected: (mode) => selected = mode,
        voiceTab: const IgnorePointer(child: SizedBox(key: Key('raised'))),
        voiceTabRaise: 44,
      ),
    );

    await tester.tap(find.text('Conversation'));

    expect(selected, TranslateInputMode.voice);
  });

  testWidgets('opening the voice tab eases the dock down', (tester) async {
    InputDock dock(TranslateInputMode mode) => InputDock(
      currentMode: mode,
      onModeSelected: (_) {},
      voiceTab: const SizedBox(key: Key('raised'), width: 76, height: 90),
      voiceTabRaise: 44,
    );
    await pumpDock(tester, dock(TranslateInputMode.keyboard));
    final closedHeight = tester.getSize(find.byType(InputDock)).height;

    await pumpDock(tester, dock(TranslateInputMode.voice));
    final startHeight = tester.getSize(find.byType(InputDock)).height;
    await tester.pumpAndSettle();
    final openHeight = tester.getSize(find.byType(InputDock)).height;

    expect(startHeight, closedHeight);
    expect(openHeight, closedHeight + 34);
  });

  testWidgets('the voice tab holds still against the dock as it eases', (
    tester,
  ) async {
    const raised = Key('raised');
    InputDock dock(TranslateInputMode mode) => InputDock(
      currentMode: mode,
      onModeSelected: (_) {},
      voiceTab: const SizedBox(key: raised, width: 76, height: 90),
      voiceTabRaise: 44,
    );
    double fromDockBottom() =>
        tester.getBottomLeft(find.byType(InputDock)).dy -
        tester.getTopLeft(find.byKey(raised)).dy;
    await pumpDock(tester, dock(TranslateInputMode.keyboard));
    final closed = fromDockBottom();

    await pumpDock(tester, dock(TranslateInputMode.voice));
    await tester.pump(const Duration(milliseconds: 100));

    expect(fromDockBottom(), closed);
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
