import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/backend_error_code.dart';
import 'package:transly_ai/core/errors/error_mapper.dart';
import 'package:transly_ai/core/errors/failure.dart';

DioException _badResponse(int statusCode, {Object? data}) {
  final request = RequestOptions(path: '/any');
  return DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: request,
      statusCode: statusCode,
      data: data,
    ),
  );
}

Map<String, dynamic> _problem(int status, String detail) => {
  'title': 'Error',
  'status': status,
  'detail': detail,
};

void main() {
  test('keeps the error key on a 401', () {
    final failure = ErrorMapper.map(
      _badResponse(401, data: _problem(401, 'auth.invalid_credentials')),
    );

    expect(failure, isA<UnauthorizedFailure>());
    expect(failure.error?.code, BackendErrorCode.invalidCredentials);
  });

  test('keeps the error key on a 429', () {
    final failure = ErrorMapper.map(
      _badResponse(429, data: _problem(429, 'translation.quota_exceeded')),
    );

    expect(failure, isA<TooManyRequestsFailure>());
    expect(failure.error?.code, BackendErrorCode.quotaExceeded);
  });

  test('keeps the error key on a 5xx', () {
    final failure = ErrorMapper.map(
      _badResponse(504, data: _problem(504, 'translation.timeout')),
    );

    expect(failure, isA<ServerFailure>());
    expect(failure.statusCode, 504);
    expect(failure.error?.code, BackendErrorCode.translationTimeout);
  });

  test('keeps the error key on a 404', () {
    final failure = ErrorMapper.map(
      _badResponse(404, data: _problem(404, 'server.unexpected_error')),
    );

    expect(failure, isA<NotFoundFailure>());
    expect(failure.error?.code, BackendErrorCode.unexpectedError);
  });

  test('maps a response without a JSON body to a failure with no error', () {
    final failure = ErrorMapper.map(_badResponse(502, data: '<html>'));

    expect(failure, isA<ServerFailure>());
    expect(failure.error, isNull);
  });

  test('maps a 422 with a body to ValidationFailure', () {
    final failure = ErrorMapper.map(
      _badResponse(422, data: _problem(422, 'Unprocessable')),
    );

    expect(failure, isA<ValidationFailure>());
    expect(failure.error, isNotNull);
  });
}
