import 'package:flutter/widgets.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/l10n/failure_message.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/password_strength.dart';
import '../../domain/entities/sign_in_form_errors.dart';
import '../../domain/entities/sign_up_form_errors.dart';

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

/// Sign-up specific wording: a 409 from register means the email is taken,
/// even when the backend sends no error key.
String signUpFailureMessage(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context)!;
  return switch (failure) {
    _ when failure.error?.code != null => failureMessage(context, failure),
    ClientFailure(statusCode: 409) => l10n.errorEmailAlreadyRegistered,
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

String? signUpPasswordErrorMessage(
  BuildContext context,
  PasswordFieldError? error,
) {
  final l10n = AppLocalizations.of(context)!;
  return switch (error) {
    null => null,
    PasswordFieldError.empty => l10n.authErrorPasswordRequired,
    PasswordFieldError.tooShort => l10n.signUpErrorPasswordTooShort,
  };
}

String? nameFieldErrorMessage(BuildContext context, NameFieldError? error) {
  final l10n = AppLocalizations.of(context)!;
  return switch (error) {
    null => null,
    NameFieldError.empty => l10n.signUpErrorNameRequired,
    NameFieldError.tooShort => l10n.signUpErrorNameTooShort,
    NameFieldError.tooLong => l10n.signUpErrorNameTooLong,
  };
}

String passwordStrengthLabel(BuildContext context, PasswordStrength strength) {
  final l10n = AppLocalizations.of(context)!;
  return switch (strength) {
    PasswordStrength.weak => l10n.signUpPasswordStrengthWeak,
    PasswordStrength.fair => l10n.signUpPasswordStrengthFair,
    PasswordStrength.strong => l10n.signUpPasswordStrengthStrong,
    PasswordStrength.veryStrong => l10n.signUpPasswordStrengthVeryStrong,
  };
}
