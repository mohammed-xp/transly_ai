import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/features/home/presentation/widgets/ui_language_listener.dart';

void main() {
  Widget app(Locale locale, VoidCallback onChanged) => MaterialApp(
    locale: locale,
    supportedLocales: const [Locale('en'), Locale('ar')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: UiLanguageListener(onChanged: onChanged, child: const SizedBox()),
  );

  testWidgets('does not fire on the first build', (tester) async {
    var calls = 0;

    await tester.pumpWidget(app(const Locale('en'), () => calls++));

    expect(calls, 0);
  });

  testWidgets('fires once when the UI language changes', (tester) async {
    var calls = 0;
    await tester.pumpWidget(app(const Locale('en'), () => calls++));

    await tester.pumpWidget(app(const Locale('ar'), () => calls++));
    await tester.pumpAndSettle();

    expect(calls, 1);
  });

  testWidgets('does not fire when the language stays the same', (tester) async {
    var calls = 0;
    await tester.pumpWidget(app(const Locale('en'), () => calls++));

    await tester.pumpWidget(app(const Locale('en', 'US'), () => calls++));
    await tester.pumpAndSettle();

    expect(calls, 0);
  });
}
