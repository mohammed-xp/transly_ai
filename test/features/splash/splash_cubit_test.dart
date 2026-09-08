import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/auth/domain/entities/remembered_account.dart';
import 'package:transly_ai/features/auth/domain/entities/user_entity.dart';
import 'package:transly_ai/features/auth/domain/repos/auth_repository.dart';
import 'package:transly_ai/features/auth/domain/usecases/has_active_session_usecase.dart';
import 'package:transly_ai/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:transly_ai/features/splash/presentation/cubit/splash_state.dart';

/// Only `hasActiveSession` is exercised by this cubit — the other members are
/// unreachable and throw if ever called by mistake.
class _FakeAuthRepository implements AuthRepository {
  ApiResult<bool> hasActiveSessionResult = const ApiResult.success(false);

  @override
  Future<ApiResult<bool>> hasActiveSession() async => hasActiveSessionResult;

  @override
  Future<ApiResult<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<ApiResult<RememberedAccount>> loadRememberedAccount() =>
      throw UnimplementedError();

  @override
  Future<ApiResult<void>> saveRememberedAccount({
    required bool remember,
    required String email,
  }) => throw UnimplementedError();

  @override
  Future<ApiResult<void>> signOut() => throw UnimplementedError();

  @override
  Stream<void> watchSessionExpired() => throw UnimplementedError();
}

SplashCubit _buildCubit(_FakeAuthRepository repo) {
  return SplashCubit(hasActiveSession: HasActiveSessionUseCase(repo));
}

void main() {
  late _FakeAuthRepository repo;

  setUp(() {
    repo = _FakeAuthRepository();
  });

  group('SplashCubit', () {
    test('starts in SplashInitializing', () {
      final cubit = _buildCubit(repo);
      addTearDown(cubit.close);

      expect(cubit.state, isA<SplashInitializing>());
    });

    test('start() emits SplashReady(isAuthenticated: true) once the minimum '
        'duration elapses when a session is persisted', () {
      fakeAsync((async) {
        repo.hasActiveSessionResult = const ApiResult.success(true);
        final cubit = _buildCubit(repo);
        final emitted = <SplashState>[];
        final sub = cubit.stream.listen(emitted.add);

        cubit.start();

        // Nothing one tick before the delay completes.
        async.elapse(
          SplashCubit.minSplashDuration - const Duration(milliseconds: 1),
        );
        expect(emitted, isEmpty);

        // Ready once the full duration has elapsed.
        async.elapse(const Duration(milliseconds: 1));
        async.flushMicrotasks();
        expect(emitted, [isA<SplashReady>()]);
        expect((emitted.single as SplashReady).isAuthenticated, isTrue);

        sub.cancel();
        cubit.close();
      });
    });

    test('start() emits SplashReady(isAuthenticated: false) when no session is '
        'persisted', () {
      fakeAsync((async) {
        repo.hasActiveSessionResult = const ApiResult.success(false);
        final cubit = _buildCubit(repo);
        final emitted = <SplashState>[];
        final sub = cubit.stream.listen(emitted.add);

        cubit.start();
        async.elapse(SplashCubit.minSplashDuration);
        async.flushMicrotasks();

        expect(emitted, [isA<SplashReady>()]);
        expect((emitted.single as SplashReady).isAuthenticated, isFalse);

        sub.cancel();
        cubit.close();
      });
    });

    test('start() emits SplashReady(isAuthenticated: false) when the session '
        'check fails', () {
      fakeAsync((async) {
        repo.hasActiveSessionResult = ApiResult.failure(
          AuthFailure(AuthFailureReason.unknown),
        );
        final cubit = _buildCubit(repo);
        final emitted = <SplashState>[];
        final sub = cubit.stream.listen(emitted.add);

        cubit.start();
        async.elapse(SplashCubit.minSplashDuration);
        async.flushMicrotasks();

        expect(emitted, [isA<SplashReady>()]);
        expect((emitted.single as SplashReady).isAuthenticated, isFalse);

        sub.cancel();
        cubit.close();
      });
    });

    test('does not emit after being closed', () {
      fakeAsync((async) {
        final cubit = _buildCubit(repo);
        final emitted = <SplashState>[];
        final sub = cubit.stream.listen(emitted.add);

        cubit.start();
        cubit.close();

        async.elapse(
          SplashCubit.minSplashDuration + const Duration(seconds: 1),
        );
        async.flushMicrotasks();
        expect(emitted, isEmpty);

        sub.cancel();
      });
    });
  });
}
