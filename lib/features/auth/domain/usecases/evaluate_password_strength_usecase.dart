import '../entities/password_strength.dart';
import 'validate_sign_up_form_usecase.dart';

/// Advisory only — any password that passes validation can be submitted.
/// Returns `null` for an empty password.
class EvaluatePasswordStrengthUseCase {
  const EvaluatePasswordStrengthUseCase();

  static const int _longLength = 12;

  static final RegExp _lower = RegExp('[a-z]');
  static final RegExp _upper = RegExp('[A-Z]');
  static final RegExp _digit = RegExp('[0-9]');
  static final RegExp _symbol = RegExp(r'[^A-Za-z0-9\s]');

  PasswordStrength? call(String password) {
    if (password.isEmpty) return null;
    if (password.length < ValidateSignUpFormUseCase.minPasswordLength) {
      return PasswordStrength.weak;
    }

    final score = [
      password.length >= _longLength,
      _lower.hasMatch(password) && _upper.hasMatch(password),
      _digit.hasMatch(password),
      _symbol.hasMatch(password),
    ].where((met) => met).length;

    return switch (score) {
      0 => PasswordStrength.weak,
      1 => PasswordStrength.fair,
      2 || 3 => PasswordStrength.strong,
      _ => PasswordStrength.veryStrong,
    };
  }
}
