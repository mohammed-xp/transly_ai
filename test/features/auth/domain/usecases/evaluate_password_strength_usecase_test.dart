import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/features/auth/domain/entities/password_strength.dart';
import 'package:transly_ai/features/auth/domain/usecases/evaluate_password_strength_usecase.dart';

void main() {
  const evaluate = EvaluatePasswordStrengthUseCase();

  test('returns null for an empty password', () {
    expect(evaluate(''), isNull);
  });

  test('rates a password shorter than 8 characters as weak', () {
    expect(evaluate('Ab1!xyz'), PasswordStrength.weak);
  });

  test('rates a long-enough password with no variety as weak', () {
    expect(evaluate('password'), PasswordStrength.weak);
  });

  test('rates a password meeting one criterion as fair', () {
    expect(evaluate('password1'), PasswordStrength.fair);
  });

  test('rates a password meeting two criteria as strong', () {
    expect(evaluate('Password1'), PasswordStrength.strong);
  });

  test('rates a password meeting three criteria as strong', () {
    expect(evaluate('Password1!'), PasswordStrength.strong);
  });

  test('rates a password meeting every criterion as very strong', () {
    expect(evaluate('Password1!long'), PasswordStrength.veryStrong);
  });
}
