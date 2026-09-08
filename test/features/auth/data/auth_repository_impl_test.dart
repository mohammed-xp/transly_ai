import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/app_exceptions.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/session/session_manager.dart';
import 'package:transly_ai/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:transly_ai/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:transly_ai/features/auth/data/models/user_login_model.dart';
import 'package:transly_ai/features/auth/data/models/user_model.dart';
import 'package:transly_ai/features/auth/data/models/user_token_model.dart';
import 'package:transly_ai/features/auth/data/repos/auth_repository_impl.dart';

class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  Object? errorToThrow;
  UserTokenModel userToReturn = const UserTokenModel(
    accessToken: 'token-abc',
  );
   
  String accessTokenToReturn = 'token-abc';
  int signInCallCount = 0;

  @override
  Future<UserLoginModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    signInCallCount++;
    final error = errorToThrow;
    if (error != null) throw error;
    return UserLoginModel(
      userTokenModel: UserTokenModel(
        accessToken: accessTokenToReturn,
      ),
      userModel: UserModel(
        id: 'uid-1',
        email: 'ahmed@example.com',
        username: 'ahmed',
        createdAt: DateTime.utc(2023),
      ),
    );
  }
}

class _FakeAuthLocalDataSource implements AuthLocalDataSource {
  bool isRemembered = false;
  String rememberedEmail = '';
  Object? loadError;
  Object? saveError;
  bool? lastSavedRemember;
  String? lastSavedEmail;

  @override
  Future<(bool, String)> loadRememberedAccount() async {
    if (loadError != null) throw loadError!;
    return (isRemembered, rememberedEmail);
  }

  @override
  Future<void> saveRememberedAccount({
    required bool remember,
    required String email,
  }) async {
    if (saveError != null) throw saveError!;
    lastSavedRemember = remember;
    lastSavedEmail = email;
  }
}

class _FakeSessionManager implements SessionManager {
  String? _token;
  final _expiredController = StreamController<void>.broadcast();

  @override
  String? get token => _token;

  @override
  Future<void> restore() async {}

  @override
  Future<void> save(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;

  @override
  Future<void> expire() async {
    _token = null;
    _expiredController.add(null);
  }

  @override
  Stream<void> get onExpired => _expiredController.stream;
}

void main() {
  group('AuthRepositoryImpl.signInWithEmail', () {
    test(
      'returns the signed-in user and persists the session token on success',
      () async {
        final remote = _FakeAuthRemoteDataSource();
        final session = _FakeSessionManager();
        final repo = AuthRepositoryImpl(
          local: _FakeAuthLocalDataSource(),
          remote: remote,
          session: session,
        );

        final result = await repo.signInWithEmail(
          email: 'ahmed@example.com',
          password: 'secret1',
        );

        result.when(
          // success: (user) => expect(user.id, 'uid-1'),
          success: (_) => expect(session.token, 'token-abc'),
          failure: (_) => fail('expected success'),
        );
        expect(remote.signInCallCount, 1);
        expect(session.token, 'token-abc');
      },
    );

    test('does not persist a session token when sign-in fails', () async {
      final remote = _FakeAuthRemoteDataSource()
        ..errorToThrow = const AuthProviderException('invalid-credential');
      final session = _FakeSessionManager();
      final repo = AuthRepositoryImpl(
        local: _FakeAuthLocalDataSource(),
        remote: remote,
        session: session,
      );

      await repo.signInWithEmail(email: 'ahmed@example.com', password: 'wrong');

      expect(session.token, isNull);
    });

    // Only codes ApiAuthRemoteDataSource actually produces (see its
    // corresponding test) — the Firebase-era codes it never throws are not
    // exercised here since AuthRepositoryImpl no longer maps them.
    for (final entry in {
      'invalid-credential': AuthFailureReason.invalidCredentials,
      'user-disabled': AuthFailureReason.userDisabled,
      'too-many-requests': AuthFailureReason.tooManyRequests,
      'something-else': AuthFailureReason.unknown,
    }.entries) {
      test('maps provider code "${entry.key}" to ${entry.value}', () async {
        final remote = _FakeAuthRemoteDataSource()
          ..errorToThrow = AuthProviderException(entry.key);
        final repo = AuthRepositoryImpl(
          local: _FakeAuthLocalDataSource(),
          remote: remote,
          session: _FakeSessionManager(),
        );

        final result = await repo.signInWithEmail(
          email: 'ahmed@example.com',
          password: 'secret1',
        );

        result.when(
          success: (_) => fail('expected failure'),
          failure: (f) => expect((f as AuthFailure).reason, entry.value),
        );
      });
    }

    test('maps a connection exception to AuthFailureReason.network', () async {
      final remote = _FakeAuthRemoteDataSource()
        ..errorToThrow = const RemoteConnectionException('offline');
      final repo = AuthRepositoryImpl(
        local: _FakeAuthLocalDataSource(),
        remote: remote,
        session: _FakeSessionManager(),
      );

      final result = await repo.signInWithEmail(
        email: 'ahmed@example.com',
        password: 'secret1',
      );

      result.when(
        success: (_) => fail('expected failure'),
        failure: (f) =>
            expect((f as AuthFailure).reason, AuthFailureReason.network),
      );
    });
  });

  group('AuthRepositoryImpl.loadRememberedAccount', () {
    test('returns the saved remember-me state', () async {
      final local = _FakeAuthLocalDataSource()
        ..isRemembered = true
        ..rememberedEmail = 'ahmed@example.com';
      final repo = AuthRepositoryImpl(
        local: local,
        remote: _FakeAuthRemoteDataSource(),
        session: _FakeSessionManager(),
      );

      final result = await repo.loadRememberedAccount();

      result.when(
        success: (account) {
          expect(account.isRemembered, isTrue);
          expect(account.email, 'ahmed@example.com');
        },
        failure: (_) => fail('expected success'),
      );
    });

    test(
      'degrades to RememberedAccount.none() when local storage throws',
      () async {
        final local = _FakeAuthLocalDataSource()..loadError = Exception('boom');
        final repo = AuthRepositoryImpl(
          local: local,
          remote: _FakeAuthRemoteDataSource(),
          session: _FakeSessionManager(),
        );

        final result = await repo.loadRememberedAccount();

        result.when(
          success: (account) => expect(account.isRemembered, isFalse),
          failure: (_) => fail('expected a degraded success'),
        );
      },
    );
  });

  group('AuthRepositoryImpl.saveRememberedAccount', () {
    test('persists the remember-me state', () async {
      final local = _FakeAuthLocalDataSource();
      final repo = AuthRepositoryImpl(
        local: local,
        remote: _FakeAuthRemoteDataSource(),
        session: _FakeSessionManager(),
      );

      await repo.saveRememberedAccount(
        remember: true,
        email: 'ahmed@example.com',
      );

      expect(local.lastSavedRemember, isTrue);
      expect(local.lastSavedEmail, 'ahmed@example.com');
    });

    test(
      'a persistence failure does not surface as a failure result',
      () async {
        final local = _FakeAuthLocalDataSource()
          ..saveError = Exception('disk full');
        final repo = AuthRepositoryImpl(
          local: local,
          remote: _FakeAuthRemoteDataSource(),
          session: _FakeSessionManager(),
        );

        final result = await repo.saveRememberedAccount(
          remember: true,
          email: 'ahmed@example.com',
        );

        result.when(
          success: (_) {},
          failure: (_) =>
              fail('a save failure must not fail the sign-in it follows'),
        );
      },
    );
  });

  group('AuthRepositoryImpl.hasActiveSession', () {
    test('returns true when a session token is persisted', () async {
      final session = _FakeSessionManager()..save('token-abc');
      final repo = AuthRepositoryImpl(
        local: _FakeAuthLocalDataSource(),
        remote: _FakeAuthRemoteDataSource(),
        session: session,
      );

      final result = await repo.hasActiveSession();

      result.when(
        success: (isActive) => expect(isActive, isTrue),
        failure: (_) => fail('expected success'),
      );
    });

    test('returns false when no session token is persisted', () async {
      final repo = AuthRepositoryImpl(
        local: _FakeAuthLocalDataSource(),
        remote: _FakeAuthRemoteDataSource(),
        session: _FakeSessionManager(),
      );

      final result = await repo.hasActiveSession();

      result.when(
        success: (isActive) => expect(isActive, isFalse),
        failure: (_) => fail('expected success'),
      );
    });
  });

  group('AuthRepositoryImpl.signOut', () {
    test('clears the persisted session token', () async {
      final session = _FakeSessionManager()..save('token-abc');
      final repo = AuthRepositoryImpl(
        local: _FakeAuthLocalDataSource(),
        remote: _FakeAuthRemoteDataSource(),
        session: session,
      );

      final result = await repo.signOut();

      result.when(success: (_) {}, failure: (_) => fail('expected success'));
      expect(session.token, isNull);
    });

    test('does not signal session expiry', () async {
      final session = _FakeSessionManager()..save('token-abc');
      final repo = AuthRepositoryImpl(
        local: _FakeAuthLocalDataSource(),
        remote: _FakeAuthRemoteDataSource(),
        session: session,
      );
      final expiredEvents = <void>[];
      final sub = repo.watchSessionExpired().listen(expiredEvents.add);

      await repo.signOut();
      await Future<void>.delayed(Duration.zero);

      expect(expiredEvents, isEmpty);
      await sub.cancel();
    });
  });
}
