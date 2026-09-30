import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
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

DioException _badResponse(int statusCode) {
  final request = RequestOptions(path: Endpoints.deleteAccount);
  return DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: request, statusCode: statusCode),
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
    'maps a 403 (wrong password) to ClientFailure with the status',
    () async {
      final repo = AccountRepoImpl(_ThrowingDataSource(_badResponse(403)));

      final result = await repo.deleteAccount(password: 'wrong');

      final failure = (result as ApiFailure<void>).failure;
      expect(failure, isA<ClientFailure>());
      expect(failure.statusCode, 403);
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
