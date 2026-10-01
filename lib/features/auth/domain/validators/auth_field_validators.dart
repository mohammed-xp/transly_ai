import '../entities/sign_in_form_errors.dart';

final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Surrounding whitespace is insignificant in an email address; trimming here
/// keeps live re-validation consistent with what a submit sends.
EmailFieldError? validateEmail(String email) {
  final trimmed = email.trim();
  return switch (trimmed) {
    '' => EmailFieldError.empty,
    _ when !_emailPattern.hasMatch(trimmed) => EmailFieldError.invalidFormat,
    _ => null,
  };
}
