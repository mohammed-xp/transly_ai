import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/data/models/error_model.dart';
import 'package:transly_ai/core/domain/entities/backend_error_code.dart';

void main() {
  test('reads a known key in a ProblemDetails detail as its code', () {
    final model = ErrorModel.fromJson({
      'title': 'Unauthorized',
      'status': 401,
      'detail': 'auth.invalid_credentials',
    });

    expect(model.code, BackendErrorCode.invalidCredentials);
    expect(model.message, 'auth.invalid_credentials');
  });

  test('leaves the code null for a plain-English detail', () {
    final model = ErrorModel.fromJson({
      'status': 401,
      'detail': 'Email or password is incorrect',
    });

    expect(model.code, isNull);
  });

  test('leaves the code null for an unknown key', () {
    final model = ErrorModel.fromJson({'detail': 'auth.something_new'});

    expect(model.code, isNull);
  });

  test('falls back to the older message envelope', () {
    final model = ErrorModel.fromJson({
      'success': false,
      'message': 'Something failed',
    });

    expect(model.message, 'Something failed');
    expect(model.code, isNull);
  });

  test('keeps validation errors and ignores a non-map errors field', () {
    final withMap = ErrorModel.fromJson({
      'errors': {
        'Email': ['The Email field is required.'],
      },
    });
    final withList = ErrorModel.fromJson({
      'errors': ['unexpected'],
    });

    expect(withMap.errors.keys, ['Email']);
    expect(withList.errors, isEmpty);
  });

  test('passes the code through to the entity', () {
    final entity = ErrorModel.fromJson({
      'detail': 'translation.quota_exceeded',
    }).toEntity();

    expect(entity.code, BackendErrorCode.quotaExceeded);
  });
}
