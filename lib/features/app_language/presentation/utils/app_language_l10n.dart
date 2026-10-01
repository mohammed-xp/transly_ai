import 'package:flutter/widgets.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/app_language.dart';

/// One per ARB file, so a new translation adds its language here.
List<String> appLanguageCodes() => [
  for (final locale in AppLocalizations.supportedLocales) locale.languageCode,
];

Locale? appLanguageLocale(AppLanguage language) {
  final code = language.code;
  return code == null ? null : Locale(code);
}

String nativeLanguageName(String code) =>
    lookupAppLocalizations(Locale(code)).languageNativeName;

String appLanguageBadge(String code) =>
    lookupAppLocalizations(Locale(code)).languageBadge;

String appLanguageLabel(BuildContext context, AppLanguage language) {
  final code = language.code;
  if (code == null) return AppLocalizations.of(context)!.appLanguageDevice;
  return nativeLanguageName(code);
}

/// The language [AppLanguage.device] currently resolves to, using the same
/// resolution `MaterialApp` applies when no locale is set.
String deviceResolvedLanguageCode(BuildContext context) {
  return basicLocaleListResolution(
    View.of(context).platformDispatcher.locales,
    AppLocalizations.supportedLocales,
  ).languageCode;
}

/// The name of [code] in the UI language. For the UI language itself that
/// would repeat its native name, so its English name is used instead; null
/// when that repeats it too.
String? secondaryLanguageName(BuildContext context, String code) {
  final nativeName = nativeLanguageName(code);
  final localized = AppLocalizations.of(context)!.languageName(code);
  if (localized.isNotEmpty && localized != nativeName) return localized;
  final english = lookupAppLocalizations(const Locale('en')).languageName(code);
  return english.isEmpty || english == nativeName ? null : english;
}
