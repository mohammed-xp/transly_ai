import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/features/auth/domain/entities/sign_in_form_errors.dart';
import 'package:transly_ai/features/auth/domain/entities/sign_up_form_errors.dart';
import 'package:transly_ai/features/auth/domain/usecases/validate_sign_up_form_usecase.dart';

void main() {
  const validate = ValidateSignUpFormUseCase();

  SignUpFormErrors run({
    String name = 'Ahmed Salem',
    String email = 'ahmed@example.com',
    String password = 'secret123',
    bool termsAccepted = true,
  }) => validate(
    name: name,
    email: email,
    password: password,
    termsAccepted: termsAccepted,
  );

  test('accepts a complete form', () {
    expect(run().isValid, isTrue);
  });

  test('flags an empty name', () {
    expect(run(name: '').name, NameFieldError.empty);
  });

  test('treats a whitespace-only name as empty', () {
    expect(run(name: '   ').name, NameFieldError.empty);
  });

  test('flags a name shorter than 3 characters after trimming', () {
    expect(run(name: ' Al ').name, NameFieldError.tooShort);
  });

  test('flags a name longer than 50 characters', () {
    expect(run(name: 'a' * 51).name, NameFieldError.tooLong);
  });

  test('accepts a name of exactly 50 characters', () {
    expect(run(name: 'a' * 50).name, isNull);
  });

  test('flags an empty email', () {
    expect(run(email: '').email, EmailFieldError.empty);
  });

  test('flags a malformed email', () {
    expect(run(email: 'ahmed@').email, EmailFieldError.invalidFormat);
  });

  test('flags an empty password', () {
    expect(run(password: '').password, PasswordFieldError.empty);
  });

  test('flags a password shorter than 8 characters', () {
    expect(run(password: '1234567').password, PasswordFieldError.tooShort);
  });

  test('accepts a password of exactly 8 characters', () {
    expect(run(password: '12345678').password, isNull);
  });

  test('flags unaccepted terms', () {
    final errors = run(termsAccepted: false);

    expect(errors.termsNotAccepted, isTrue);
    expect(errors.isValid, isFalse);
  });
}
