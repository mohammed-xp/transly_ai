import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/features/auth/domain/entities/sign_in_form_errors.dart';
import 'package:transly_ai/features/auth/domain/usecases/validate_sign_in_form_usecase.dart';

void main() {
  const validate = ValidateSignInFormUseCase();

  group('ValidateSignInFormUseCase', () {
    test('valid email and password produce no errors', () {
      final errors = validate(email: 'ahmed@example.com', password: 'secret1');

      expect(errors.isValid, isTrue);
      expect(errors.email, isNull);
      expect(errors.password, isNull);
    });

    test('empty email is flagged as empty, not invalid format', () {
      final errors = validate(email: '', password: 'secret1');

      expect(errors.email, EmailFieldError.empty);
    });

    test('malformed email is flagged as invalid format', () {
      final errors = validate(email: 'not-an-email', password: 'secret1');

      expect(errors.email, EmailFieldError.invalidFormat);
    });

    test('empty password is flagged as empty, not too short', () {
      final errors = validate(email: 'ahmed@example.com', password: '');

      expect(errors.password, PasswordFieldError.empty);
    });

    test('password shorter than 6 characters is flagged as too short', () {
      final errors = validate(email: 'ahmed@example.com', password: '123');

      expect(errors.password, PasswordFieldError.tooShort);
    });

    test('both fields invalid are reported together', () {
      final errors = validate(email: '', password: '');

      expect(errors.isValid, isFalse);
      expect(errors.email, EmailFieldError.empty);
      expect(errors.password, PasswordFieldError.empty);
    });
  });
}
