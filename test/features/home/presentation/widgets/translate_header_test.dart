import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/features/home/presentation/widgets/translate_header.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

void main() {
  Future<void> pumpHeader(
    WidgetTester tester, {
    required bool isPro,
    Locale locale = const Locale('en'),
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppPalette.light]),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TranslateHeader(
            userName: 'Ahmed Hassan',
            isPro: isPro,
            onProfileTap: () {},
          ),
        ),
      ),
    );
  }

  bool hasDot(WidgetTester tester, Color color) {
    return tester.widgetList<Container>(find.byType(Container)).any((box) {
      final decoration = box.decoration;
      return decoration is BoxDecoration &&
          decoration.shape == BoxShape.circle &&
          decoration.color == color;
    });
  }

  testWidgets('a free user sees "AI Free" with a muted dot', (tester) async {
    await pumpHeader(tester, isPro: false);

    expect(find.text('AI Free'), findsOneWidget);
    expect(find.text('AI Pro'), findsNothing);
    expect(hasDot(tester, AppPalette.light.textMuted), isTrue);
    expect(hasDot(tester, AppPalette.light.coral), isFalse);
  });

  testWidgets('a Pro user sees "AI Pro" with a coral dot', (tester) async {
    await pumpHeader(tester, isPro: true);

    expect(find.text('AI Pro'), findsOneWidget);
    expect(find.text('AI Free'), findsNothing);
    expect(hasDot(tester, AppPalette.light.coral), isTrue);
    expect(hasDot(tester, AppPalette.light.textMuted), isFalse);
  });

  testWidgets('the badge keeps its Latin label in Arabic', (tester) async {
    await pumpHeader(tester, isPro: false, locale: const Locale('ar'));

    expect(find.text('AI Free'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
