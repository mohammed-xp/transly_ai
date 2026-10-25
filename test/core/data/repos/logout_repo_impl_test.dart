import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/data/datasources/user_local_data_source.dart';
import 'package:transly_ai/core/data/repos/logout_repo_impl.dart';
import 'package:transly_ai/core/errors/app_exceptions.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';

import '../../../helpers/fake_google_auth_data_source.dart';

class _FakeUserLocal implements UserLocalDataSource {
  _FakeUserLocal({this.clearCachedUserDataError, this.clearTokensError});

  final Object? clearCachedUserDataError;
  final Object? clearTokensError;

  bool cachedUserCleared = false;
  bool tokensCleared = false;

  @override
  Future<void> clearCachedUserData() async {
    final error = clearCachedUserDataError;
    if (error != null) throw error;
    cachedUserCleared = true;
  }

  @override
  Future<void> clearTokens() async {
    final error = clearTokensError;
    if (error != null) throw error;
    tokensCleared = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  late FakeGoogleAuthDataSource google;

  setUp(() {
    google = FakeGoogleAuthDataSource();
  });

  test(
    'clears the cached user, the tokens and the Google sign-in, and succeeds',
    () async {
      final userLocal = _FakeUserLocal();

      final result = await LogoutRepoImpl(userLocal, google).logout();

      expect(result, isA<ApiSuccess<void>>());
      expect(userLocal.cachedUserCleared, isTrue);
      expect(userLocal.tokensCleared, isTrue);
      expect(google.signOuts, 1);
    },
  );

  test('clears the tokens even when clearing the cached user fails', () async {
    final userLocal = _FakeUserLocal(
      clearCachedUserDataError: const UnknownException(),
    );

    await LogoutRepoImpl(userLocal, google).logout();

    expect(userLocal.tokensCleared, isTrue);
  });

  test('clears the cached user even when clearing the tokens fails', () async {
    final userLocal = _FakeUserLocal(
      clearTokensError: const UnknownException(),
    );

    await LogoutRepoImpl(userLocal, google).logout();

    expect(userLocal.cachedUserCleared, isTrue);
  });

  test('signs out of Google even when a local step fails', () async {
    final userLocal = _FakeUserLocal(
      clearTokensError: const UnknownException(),
    );

    await LogoutRepoImpl(userLocal, google).logout();

    expect(google.signOuts, 1);
  });

  test('returns a failure when a step fails', () async {
    final userLocal = _FakeUserLocal(
      clearTokensError: const UnknownException(),
    );

    final result = await LogoutRepoImpl(userLocal, google).logout();

    expect((result as ApiFailure<void>).failure, isA<UnknownFailure>());
  });

  test('reports the first error when several steps fail', () async {
    final userLocal = _FakeUserLocal(
      clearTokensError: const NetworkException(),
      clearCachedUserDataError: const UnknownException(),
    );

    final result = await LogoutRepoImpl(userLocal, google).logout();

    expect((result as ApiFailure<void>).failure, isA<NetworkFailure>());
  });
}
