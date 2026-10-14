import 'dart:ui';

import '../../l10n/app_localizations.dart';

/// Short mark for the language with [code] on its row badge: the one its ARB
/// file gives it when the app is translated into it, its code otherwise.
String languageBadge(String code) {
  final locale = Locale(code);
  if (AppLocalizations.supportedLocales.contains(locale)) {
    return lookupAppLocalizations(locale).languageBadge;
  }
  return code.split('-').first.toUpperCase();
}
