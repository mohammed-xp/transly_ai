import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../domain/entities/language_entity.dart';

/// Name of [language] in the app's UI language, falling back to the name the
/// backend sent for languages without a localized label yet.
String languageLabel(BuildContext context, LanguageEntity language) {
  final l10n = AppLocalizations.of(context)!;
  return switch (language.code) {
    'en' => l10n.languageEnglish,
    'ar' => l10n.languageArabic,
    _ => language.name,
  };
}
