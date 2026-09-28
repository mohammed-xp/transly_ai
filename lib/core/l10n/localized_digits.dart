import 'package:flutter/widgets.dart';

import '../domain/entities/language_entity.dart';

const String _arabicIndicDigits = '٠١٢٣٤٥٦٧٨٩';

/// [value] written in the UI language's digits. `intl` formats `ar` with
/// Latin digits, while the design writes Arabic numbers in Arabic-Indic ones
/// (٧٠٪, ٦ ساعات).
String localizedDigits(BuildContext context, int value) {
  final latin = value.toString();
  if (Localizations.localeOf(context).languageCode !=
      LanguageEntity.arabic.code) {
    return latin;
  }
  return latin.replaceAllMapped(
    RegExp('[0-9]'),
    (match) => _arabicIndicDigits[int.parse(match[0]!)],
  );
}
