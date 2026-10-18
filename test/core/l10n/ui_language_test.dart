import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/l10n/ui_language.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

void main() {
  test('uses the chosen language over the device one', () {
    expect(resolveUiLanguageCode('ar', const [Locale('en')]), 'ar');
  });

  test('follows a supported device language', () {
    expect(resolveUiLanguageCode(null, const [Locale('ar', 'EG')]), 'ar');
  });

  test('an unsupported device language resolves to the first locale', () {
    expect(
      resolveUiLanguageCode(null, const [Locale('xx')]),
      AppLocalizations.supportedLocales.first.languageCode,
    );
  });
}
