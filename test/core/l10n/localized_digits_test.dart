import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/l10n/localized_digits.dart';

void main() {
  Future<String> digitsIn(WidgetTester tester, Locale locale, int value) async {
    late String result;
    await tester.pumpWidget(
      Localizations(
        locale: locale,
        delegates: const [DefaultWidgetsLocalizations.delegate],
        child: Builder(
          builder: (context) {
            result = localizedDigits(context, value);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return result;
  }

  testWidgets('writes Arabic-Indic digits in Arabic', (tester) async {
    expect(
      await digitsIn(tester, const Locale('ar'), 1234567890),
      '١٢٣٤٥٦٧٨٩٠',
    );
  });

  testWidgets('keeps Latin digits in English', (tester) async {
    expect(await digitsIn(tester, const Locale('en'), 70), '70');
  });
}
