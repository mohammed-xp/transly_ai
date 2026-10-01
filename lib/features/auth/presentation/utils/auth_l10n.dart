import 'package:flutter/widgets.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/l10n/failure_message.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/sign_in_form_errors.dart';

/// Sign-in specific wording: a 401 from the login endpoint means wrong
/// credentials, not an expired session. A backend error key, when sent, is
/// more precise than either and wins.
String authFailureMessage(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context)!;
  return switch (failure) {
    _ when failure.error?.code != null => failureMessage(context, failure),
    UnauthorizedFailure() => l10n.authErrorInvalidCredentials,
    TooManyRequestsFailure() => l10n.authErrorTooManyRequests,
    NetworkFailure() => l10n.authErrorNoConnection,
    _ => failureMessage(context, failure),
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
