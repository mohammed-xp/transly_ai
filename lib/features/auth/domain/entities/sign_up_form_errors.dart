import 'sign_in_form_errors.dart';

enum NameFieldError { empty, tooShort, tooLong }

/// Validation result for the sign-up form. `null` fields mean that field is
/// valid.
class SignUpFormErrors {
  const SignUpFormErrors({
    this.name,
    this.email,
    this.password,
    this.termsNotAccepted = false,
  });

  const SignUpFormErrors.none()
    : name = null,
      email = null,
      password = null,
      termsNotAccepted = false;

  final NameFieldError? name;
  final EmailFieldError? email;
  final PasswordFieldError? password;
  final bool termsNotAccepted;

  bool get isValid =>
      name == null && email == null && password == null && !termsNotAccepted;
}
