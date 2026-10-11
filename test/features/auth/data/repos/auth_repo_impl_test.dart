import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/data/datasources/user_local_data_source.dart';
import 'package:transly_ai/core/data/models/user_model.dart';
import 'package:transly_ai/core/domain/entities/user_entity.dart';
import 'package:transly_ai/core/errors/app_exceptions.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/network/endpoints.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:transly_ai/features/auth/data/repos/auth_repo_impl.dart';

import '../../../../helpers/fake_api_consumer.dart';
import '../../../../helpers/fake_google_auth_data_source.dart';

class _UnusedUserLocal implements UserLocalDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

/// Records what a successful sign-in persists; everything else is unused.
class _RecordingUserLocal implements UserLocalDataSource {
  UserModel? cachedUser;
  String? signInMethod;
  String? accessToken;
  String? refreshToken;

  @override
  Future<void> cacheUserData(UserModel data) async {
    cachedUser = data;
  }

  @override
  Future<void> cacheSignInMethod(String method) async {
    signInMethod = method;
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

const Map<String, dynamic> _loginResponse = {
  'data': {
    'token': {'accessToken': 'access-1', 'refreshToken': 'refresh-1'},
    'user': {
      'id': 'u1',
      'email': 'ahmed@example.com',
      'userName': 'Ahmed Salem',
      'createdAt': '2026-10-01T10:00:00Z',
    },
  },
};

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

AuthRepoImpl _repo(
  FakeApiConsumer api, {
  UserLocalDataSource? userLocal,
  FakeGoogleAuthDataSource? google,
}) => AuthRepoImpl(
  remote: AuthRemoteDataSourceImpl(api),
  userLocal: userLocal ?? _UnusedUserLocal(),
  google: google ?? FakeGoogleAuthDataSource(),
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

  test('remembers that the session was started with email', () async {
    final userLocal = _RecordingUserLocal();

    await _repo(
      FakeApiConsumer(_loginResponse),
      userLocal: userLocal,
    ).signInWithEmail(email: 'ahmed@example.com', password: 'secret123');

    expect(userLocal.signInMethod, 'email');
  });

  group('signInWithGoogle', () {
    test('posts the Google ID token and stores the session', () async {
      final api = FakeApiConsumer(_loginResponse);
      final userLocal = _RecordingUserLocal();

      final result = await _repo(
        api,
        userLocal: userLocal,
        google: FakeGoogleAuthDataSource(idToken: 'google-id-token'),
      ).signInWithGoogle();

      final user = (result as ApiSuccess<UserEntity?>).data;
      expect(user?.email, 'ahmed@example.com');
      final (url, body) = api.postRequests.single;
      expect(url, Endpoints.googleLogin);
      expect(body, {'idToken': 'google-id-token'});
      expect(userLocal.cachedUser?.id, 'u1');
      expect(userLocal.accessToken, 'access-1');
      expect(userLocal.refreshToken, 'refresh-1');
    });

    test('remembers that the session was started with Google', () async {
      final userLocal = _RecordingUserLocal();

      await _repo(
        FakeApiConsumer(_loginResponse),
        userLocal: userLocal,
        google: FakeGoogleAuthDataSource(idToken: 'google-id-token'),
      ).signInWithGoogle();

      expect(userLocal.signInMethod, 'google');
    });

    test('skips the API when the account picker is closed', () async {
      final api = FakeApiConsumer(_loginResponse);

      final result = await _repo(api).signInWithGoogle();

      expect((result as ApiSuccess<UserEntity?>).data, isNull);
      expect(api.postRequests, isEmpty);
    });

    test('maps a Google SDK failure to UnknownFailure', () async {
      final api = FakeApiConsumer(_loginResponse);

      final result = await _repo(
        api,
        google: FakeGoogleAuthDataSource(error: const UnknownException()),
      ).signInWithGoogle();

      expect(
        (result as ApiFailure<UserEntity?>).failure,
        isA<UnknownFailure>(),
      );
      expect(api.postRequests, isEmpty);
    });

    test('maps a rejected ID token (401) to UnauthorizedFailure', () async {
      final api = _ThrowingApiConsumer(_badResponse(401));

      final result = await _repo(
        api,
        google: FakeGoogleAuthDataSource(idToken: 'google-id-token'),
      ).signInWithGoogle();

      expect(
        (result as ApiFailure<UserEntity?>).failure,
        isA<UnauthorizedFailure>(),
      );
    });
  });
}
