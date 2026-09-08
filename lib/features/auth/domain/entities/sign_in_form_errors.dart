/// Field-level validation problems for the sign-in form. Pure Dart — mapped to
/// localized text only in the presentation layer (CLAUDE.md §B-5).
enum EmailFieldError { empty, invalidFormat }

enum PasswordFieldError { empty, tooShort }

/// Validation result for the whole form. `null` fields mean that field is
/// valid.
class SignInFormErrors {
  const SignInFormErrors({this.email, this.password});

  const SignInFormErrors.none() : email = null, password = null;

  final EmailFieldError? email;
  final PasswordFieldError? password;

  bool get isValid => email == null && password == null;
}
