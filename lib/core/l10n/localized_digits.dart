import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

/// [value] written in the UI language's digits, as listed in its ARB file.
/// `intl` formats `ar` with Latin digits, while the design writes Arabic
/// numbers in Arabic-Indic ones (٧٠٪, ٦ ساعات).
String localizedDigits(BuildContext context, int value) {
  final latin = value.toString();
  final digits = AppLocalizations.of(context)!.localeDigits.characters;
  if (digits.length != 10) return latin;
  return latin.replaceAllMapped(
    RegExp('[0-9]'),
    (match) => digits.elementAt(int.parse(match[0]!)),
  );
}
