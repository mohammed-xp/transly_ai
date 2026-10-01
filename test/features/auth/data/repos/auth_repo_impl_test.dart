import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/data/datasources/user_local_data_source.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/network/endpoints.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:transly_ai/features/auth/data/repos/auth_repo_impl.dart';

import '../../../../helpers/fake_api_consumer.dart';

class _UnusedUserLocal implements UserLocalDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _ThrowingApiConsumer extends FakeApiConsumer {
  _ThrowingApiConsumer(this.error);

  final Object error;

  @override
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? data,
    FormData? formData,
    Map<String, dynamic>? queryParameters,
  }) async => throw error;
}

DioException _badResponse(int statusCode, {Object? data}) {
  final request = RequestOptions(path: Endpoints.register);
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

AuthRepoImpl _repo(FakeApiConsumer api) => AuthRepoImpl(
  remote: AuthRemoteDataSourceImpl(api),
  userLocal: _UnusedUserLocal(),
);

void main() {
  test('posts the name as userName to register', () async {
    final api = FakeApiConsumer();

    final result = await _repo(api).signUpWithEmail(
      name: 'Ahmed Salem',
      email: 'ahmed@example.com',
      password: 'secret123',
    );

    expect(result, isA<ApiSuccess<void>>());
    final (url, body) = api.postRequests.single;
    expect(url, Endpoints.register);
    expect(body, {
      'email': 'ahmed@example.com',
      'userName': 'Ahmed Salem',
      'password': 'secret123',
    });
  });

  test('maps a 409 conflict to ClientFailure', () async {
    final api = _ThrowingApiConsumer(
      _badResponse(
        409,
        data: {
          'status': 409,
          'detail': "User with email 'ahmed@example.com' already exists",
        },
      ),
    );

    final result = await _repo(api).signUpWithEmail(
      name: 'Ahmed Salem',
      email: 'ahmed@example.com',
      password: 'secret123',
    );

    final failure = (result as ApiFailure<void>).failure;
    expect(failure, isA<ClientFailure>());
    expect(failure.statusCode, 409);
  });

  test('maps a connection error to NetworkFailure', () async {
    final api = _ThrowingApiConsumer(
      DioException(
        requestOptions: RequestOptions(path: Endpoints.register),
        type: DioExceptionType.connectionError,
      ),
    );

    final result = await _repo(api).signUpWithEmail(
      name: 'Ahmed Salem',
      email: 'ahmed@example.com',
      password: 'secret123',
    );

    expect((result as ApiFailure<void>).failure, isA<NetworkFailure>());
  });
}
