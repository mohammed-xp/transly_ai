import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../domain/entities/language_entity.dart';

String languageLabel(BuildContext context, LanguageEntity language) {
  final localized = AppLocalizations.of(context)!.languageName(language.code);
  return localized.isEmpty ? language.name : localized;
}
