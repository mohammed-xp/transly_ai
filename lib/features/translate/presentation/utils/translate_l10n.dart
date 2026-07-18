import 'package:flutter/widgets.dart';

import '../../../../core/errors/failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/language.dart';

/// Presentation-only mappers from domain values to localized strings. Keeps the
/// domain/data layers free of UI text (CLAUDE.md §B-5).

String languageLabel(BuildContext context, Language language) {
  final l10n = AppLocalizations.of(context)!;
  return switch (language) {
    Language.english => l10n.languageEnglish,
    Language.arabic => l10n.languageArabic,
  };
}

String failureMessage(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context)!;
  return switch (failure) {
    ModelDownloadFailure() => l10n.translateErrorModelDownload,
    NoConnectionFailure() => l10n.translateErrorNoConnection,
    TranslationFailure() => l10n.translateErrorGeneric,
    UnknownFailure() => l10n.translateErrorGeneric,
  };
}
