import '../entities/sign_in_form_errors.dart';

/// Validates the sign-in form's raw field values. No I/O, no repository
/// dependency — kept as a use case (rather than inline in the cubit) so
/// `SignInCubit` depends only on use cases (CLAUDE.md §B-1).
class ValidateSignInFormUseCase {
  const ValidateSignInFormUseCase();

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static const int _minPasswordLength = 6;

  SignInFormErrors call({required String email, required String password}) {
    // Surrounding whitespace is insignificant in an email address; trimming
    // here keeps live re-validation consistent with what `submit()` sends.
    final trimmedEmail = email.trim();

    final EmailFieldError? emailError = switch (trimmedEmail) {
      '' => EmailFieldError.empty,
      _ when !_emailPattern.hasMatch(trimmedEmail) =>
        EmailFieldError.invalidFormat,
      _ => null,
    };

    final PasswordFieldError? passwordError = switch (password) {
      '' => PasswordFieldError.empty,
      _ when password.length < _minPasswordLength =>
        PasswordFieldError.tooShort,
      _ => null,
    };

    return SignInFormErrors(email: emailError, password: passwordError);
  }
}
