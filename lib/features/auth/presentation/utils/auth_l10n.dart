import 'package:flutter/widgets.dart';

import '../../../../core/errors/failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/sign_in_form_errors.dart';

/// Presentation-only mappers from domain values to localized strings. Keeps
/// the domain/data layers free of UI text (CLAUDE.md §B-5).

String authFailureMessage(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context)!;
  if (failure is! AuthFailure) return l10n.authErrorGeneric;
  return switch (failure.reason) {
    AuthFailureReason.invalidCredentials => l10n.authErrorInvalidCredentials,
    AuthFailureReason.userDisabled => l10n.authErrorUserDisabled,
    AuthFailureReason.tooManyRequests => l10n.authErrorTooManyRequests,
    AuthFailureReason.network => l10n.authErrorNoConnection,
    AuthFailureReason.unavailable => l10n.authErrorUnavailable,
    AuthFailureReason.unknown => l10n.authErrorGeneric,
  };
}

String? emailFieldErrorMessage(BuildContext context, EmailFieldError? error) {
  final l10n = AppLocalizations.of(context)!;
  return switch (error) {
    null => null,
    EmailFieldError.empty => l10n.authErrorEmailRequired,
    EmailFieldError.invalidFormat => l10n.authErrorEmailInvalid,
  };
}

String? passwordFieldErrorMessage(
  BuildContext context,
  PasswordFieldError? error,
) {
  final l10n = AppLocalizations.of(context)!;
  return switch (error) {
    null => null,
    PasswordFieldError.empty => l10n.authErrorPasswordRequired,
    PasswordFieldError.tooShort => l10n.authErrorPasswordTooShort,
  };
}
