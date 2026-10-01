import '../entities/sign_in_form_errors.dart';
import '../entities/sign_up_form_errors.dart';
import '../validators/auth_field_validators.dart';

/// Validates the sign-up form against the backend's register limits.
class ValidateSignUpFormUseCase {
  const ValidateSignUpFormUseCase();

  static const int minNameLength = 3;
  static const int maxNameLength = 50;
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;

  SignUpFormErrors call({
    required String name,
    required String email,
    required String password,
    required bool termsAccepted,
  }) {
    final trimmedName = name.trim();
    final NameFieldError? nameError = switch (trimmedName.length) {
      0 => NameFieldError.empty,
      < minNameLength => NameFieldError.tooShort,
      > maxNameLength => NameFieldError.tooLong,
      _ => null,
    };

    final PasswordFieldError? passwordError = switch (password) {
      '' => PasswordFieldError.empty,
      _ when password.length < minPasswordLength => PasswordFieldError.tooShort,
      _ => null,
    };

    return SignUpFormErrors(
      name: nameError,
      email: validateEmail(email),
      password: passwordError,
      termsNotAccepted: !termsAccepted,
    );
  }
}
