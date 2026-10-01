import '../entities/sign_in_form_errors.dart';
import '../validators/auth_field_validators.dart';

/// Validates the sign-in form's raw field values. No I/O, no repository
/// dependency — kept as a use case (rather than inline in the cubit) so
/// `SignInCubit` depends only on use cases (CLAUDE.md §B-1).
class ValidateSignInFormUseCase {
  const ValidateSignInFormUseCase();

  static const int _minPasswordLength = 6;

  SignInFormErrors call({required String email, required String password}) {
    final PasswordFieldError? passwordError = switch (password) {
      '' => PasswordFieldError.empty,
      _ when password.length < _minPasswordLength =>
        PasswordFieldError.tooShort,
      _ => null,
    };

    return SignInFormErrors(
      email: validateEmail(email),
      password: passwordError,
    );
  }
}
