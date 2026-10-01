import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/backend_error_code.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/network/endpoints.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/profile/data/datasources/account_remote_data_source.dart';
import 'package:transly_ai/features/profile/data/datasources/account_remote_data_source_impl.dart';
import 'package:transly_ai/features/profile/data/repos/account_repo_impl.dart';

import '../../../../helpers/fake_api_consumer.dart';

class _ThrowingDataSource implements AccountRemoteDataSource {
  _ThrowingDataSource(this.error);

  final Object error;

  @override
  Future<void> deleteAccount({required String password}) async => throw error;
}

DioException _badResponse(int statusCode, {Object? data}) {
  final request = RequestOptions(path: Endpoints.deleteAccount);
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

void main() {
  test('sends the password in a DELETE to delete-account', () async {
    final api = FakeApiConsumer();
    final repo = AccountRepoImpl(AccountRemoteDataSourceImpl(api));

    final result = await repo.deleteAccount(password: 'secret123');

    expect(result, isA<ApiSuccess<void>>());
    final (url, body) = api.deleteRequests.single;
    expect(url, Endpoints.deleteAccount);
    expect(body, {'password': 'secret123'});
  });

  test(
    'maps a wrong-password 400 to ClientFailure with its error key',
    () async {
      final repo = AccountRepoImpl(
        _ThrowingDataSource(
          _badResponse(
            400,
            data: {'status': 400, 'detail': 'account.wrong_password'},
          ),
        ),
      );

      final result = await repo.deleteAccount(password: 'wrong');

      final failure = (result as ApiFailure<void>).failure;
      expect(failure, isA<ClientFailure>());
      expect(failure.statusCode, 400);
      expect(failure.error?.code, BackendErrorCode.wrongPassword);
    },
  );

  test('maps a connection error to NetworkFailure', () async {
    final repo = AccountRepoImpl(
      _ThrowingDataSource(
        DioException(
          requestOptions: RequestOptions(path: Endpoints.deleteAccount),
          type: DioExceptionType.connectionError,
        ),
      ),
    );

    final result = await repo.deleteAccount(password: 'secret123');

    expect((result as ApiFailure<void>).failure, isA<NetworkFailure>());
  });
}
