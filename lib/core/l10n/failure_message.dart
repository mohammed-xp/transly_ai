import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../domain/entities/backend_error_code.dart';
import '../errors/failure.dart';

/// User-facing text for [failure], in the app's current language. A known
/// backend error key wins; otherwise the message follows the failure type.
/// The backend's raw text is never shown — it is an untranslated key.
/// Both switches are exhaustive, so a new failure type or error key is a
/// compile error until it gets a message here.
String failureMessage(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context)!;
  final code = failure.error?.code;
  if (code != null) return _backendErrorMessage(l10n, code);

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

String _backendErrorMessage(AppLocalizations l10n, BackendErrorCode code) {
  return switch (code) {
    BackendErrorCode.emailAlreadyRegistered => l10n.errorEmailAlreadyRegistered,
    BackendErrorCode.invalidCredentials => l10n.authErrorInvalidCredentials,
    BackendErrorCode.invalidToken => l10n.errorUnauthorized,
    BackendErrorCode.wrongPassword => l10n.profileDeleteAccountWrongPassword,
    BackendErrorCode.quotaExceeded => l10n.errorQuotaExceeded,
    BackendErrorCode.textTooLong => l10n.errorTextTooLong,
    BackendErrorCode.translationServiceUnavailable =>
      l10n.errorTranslationUnavailable,
    BackendErrorCode.translationTimeout => l10n.errorTranslationTimeout,
    BackendErrorCode.translationFailed => l10n.translateErrorGeneric,
    BackendErrorCode.unexpectedError => l10n.errorServer,
  };
}
