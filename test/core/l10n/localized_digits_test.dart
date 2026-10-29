import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/l10n/localized_digits.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

void main() {
  Future<String> localize(
    WidgetTester tester,
    Locale locale,
    String Function(BuildContext context) format,
  ) async {
    late String result;
    await tester.pumpWidget(
      Localizations(
        locale: locale,
        delegates: AppLocalizations.localizationsDelegates,
        child: Builder(
          builder: (context) {
            result = format(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return result;
  }

  Future<String> digitsIn(WidgetTester tester, Locale locale, int value) =>
      localize(tester, locale, (context) => localizedDigits(context, value));

  testWidgets('writes Arabic-Indic digits in Arabic', (tester) async {
    expect(
      await digitsIn(tester, const Locale('ar'), 1234567890),
      '١٢٣٤٥٦٧٨٩٠',
    );
  });

  testWidgets('keeps Latin digits in English', (tester) async {
    expect(await digitsIn(tester, const Locale('en'), 70), '70');
  });

  testWidgets('swaps only the digits of formatted text in Arabic', (
    tester,
  ) async {
    expect(
      await localize(
        tester,
        const Locale('ar'),
        (context) => localizedDigitsIn(context, '10:24'),
      ),
      '١٠:٢٤',
    );
  });

  testWidgets('leaves formatted text alone in English', (tester) async {
    expect(
      await localize(
        tester,
        const Locale('en'),
        (context) => localizedDigitsIn(context, '10:24'),
      ),
      '10:24',
    );
  });
}
