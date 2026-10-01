import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

/// The ARB files are the only list of app languages. The compiler can't see
/// a language whose name is missing from another file, so these checks do.
void main() {
  final codes = [
    for (final locale in AppLocalizations.supportedLocales) locale.languageCode,
  ];

  for (final code in codes) {
    group('app_$code.arb', () {
      final l10n = lookupAppLocalizations(Locale(code));

      test('names its own language', () {
        expect(l10n.languageNativeName.trim(), isNotEmpty);
      });

      test('has a badge for the language picker', () {
        expect(l10n.languageBadge.trim(), isNotEmpty);
      });

      test('lists exactly ten digits', () {
        expect(l10n.localeDigits.characters.length, 10);
      });

      for (final other in codes) {
        test('has a languageName case for "$other"', () {
          expect(
            l10n.languageName(other),
            isNotEmpty,
            reason: 'Add $other{…} to languageName in app_$code.arb',
          );
        });
      }
    });
  }
}
