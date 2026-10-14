import 'package:flutter/widgets.dart';

import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/l10n/language_label.dart';

/// The line under [language]'s native name: its name in the UI language, or
/// its English name when that would repeat the native one. Null when both do.
String? secondaryLanguageLabel(BuildContext context, LanguageEntity language) {
  final localized = languageLabel(context, language);
  if (localized != language.nativeName) return localized;
  return language.name == language.nativeName ? null : language.name;
}
