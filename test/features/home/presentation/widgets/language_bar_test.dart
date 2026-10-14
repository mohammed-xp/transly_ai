import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/features/home/presentation/widgets/language_bar.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

void main() {
  late List<String> taps;

  Future<void> pumpBar(WidgetTester tester) async {
    taps = [];
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppPalette.light]),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LanguageBar(
            fromLanguage: 'English',
            toLanguage: 'Arabic',
            onSwap: () => taps.add('swap'),
            onFromTap: () => taps.add('from'),
            onToTap: () => taps.add('to'),
            isBusy: false,
          ),
        ),
      ),
    );
  }

  testWidgets('tapping the source language opens the source picker', (
    tester,
  ) async {
    await pumpBar(tester);

    await tester.tap(find.text('English'));

    expect(taps, ['from']);
  });

  testWidgets('tapping the target language opens the target picker', (
    tester,
  ) async {
    await pumpBar(tester);

    await tester.tap(find.text('Arabic'));

    expect(taps, ['to']);
  });

  testWidgets('the swap button swaps', (tester) async {
    await pumpBar(tester);

    await tester.tap(find.byIcon(Icons.swap_horiz_rounded));

    expect(taps, ['swap']);
  });
}
