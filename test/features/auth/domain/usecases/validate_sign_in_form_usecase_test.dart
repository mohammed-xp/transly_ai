import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/features/auth/domain/entities/sign_in_form_errors.dart';
import 'package:transly_ai/features/auth/domain/usecases/validate_sign_in_form_usecase.dart';

void main() {
  const validate = ValidateSignInFormUseCase();

  test('accepts an email with surrounding whitespace', () {
    final errors = validate(email: ' ahmed@example.com ', password: 'secret');

    expect(errors.isValid, isTrue);
  });

  test('flags a malformed email', () {
    final errors = validate(email: 'ahmed@example', password: 'secret');

    expect(errors.email, EmailFieldError.invalidFormat);
  });

  test('keeps the 6-character minimum for sign-in passwords', () {
    final errors = validate(email: 'ahmed@example.com', password: 'secre');

    expect(errors.password, PasswordFieldError.tooShort);
  });
}
