import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

/// The language the UI is shown in: [chosenCode] when the user picked one,
/// otherwise the best match for [deviceLocales] — the same resolution
/// `MaterialApp` applies when no locale is set.
String resolveUiLanguageCode(String? chosenCode, List<Locale> deviceLocales) {
  return chosenCode ??
      basicLocaleListResolution(
        deviceLocales,
        AppLocalizations.supportedLocales,
      ).languageCode;
}
