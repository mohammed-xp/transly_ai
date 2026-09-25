import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../errors/failure.dart';

/// User-facing text for [failure]. Prefers the backend's own message when it
/// sent one; otherwise the switch is exhaustive over the sealed [Failure], so
/// adding a new failure type is a compile error until it gets a message here.
String failureMessage(BuildContext context, Failure failure) {
  final backendMessage = failure.error?.message.trim();
  if (backendMessage != null &&
      backendMessage.isNotEmpty &&
      backendMessage != '---') {
    return backendMessage;
  }

  final l10n = AppLocalizations.of(context)!;
  return switch (failure) {
    NetworkFailure() => l10n.errorNetwork,
    ServerFailure() => l10n.errorServer,
    UnauthorizedFailure() => l10n.errorUnauthorized,
    ValidationFailure() => l10n.errorValidation,
    NotFoundFailure() => l10n.errorNotFound,
    ClientFailure() => l10n.errorClient,
    TooManyRequestsFailure() => l10n.errorTooManyRequests,
    FormatFailure() => l10n.errorFormat,
    UnsupportedLanguageFailure() => l10n.errorUnsupportedLanguage,
    ModelDownloadFailure() => l10n.translateErrorModelDownload,
    UnknownFailure() => l10n.errorUnknown,
  };
}
