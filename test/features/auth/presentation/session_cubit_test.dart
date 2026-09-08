import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/auth/domain/entities/user_entity.dart';
import 'package:transly_ai/features/auth/domain/entities/remembered_account.dart';
import 'package:transly_ai/features/auth/domain/repos/auth_repository.dart';
import 'package:transly_ai/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:transly_ai/features/auth/domain/usecases/watch_session_expired_usecase.dart';
import 'package:transly_ai/features/auth/presentation/cubit/session_cubit.dart';
import 'package:transly_ai/features/auth/presentation/cubit/session_state.dart';

/// Only `watchSessionExpired` and `signOut` are exercised by this cubit — the
/// other members are unreachable and throw if ever called by mistake.
class _FakeAuthRepository implements AuthRepository {
  final _expiredController = StreamController<void>.broadcast();
  int signOutCallCount = 0;

  void emitExpired() => _expiredController.add(null);

  @override
  Stream<void> watchSessionExpired() => _expiredController.stream;

  @override
  Future<ApiResult<void>> signOut() async {
    signOutCallCount++;
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<bool>> hasActiveSession() => throw UnimplementedError();

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
}

void main() {
  late _FakeAuthRepository repo;
  late SessionCubit cubit;

  setUp(() {
    repo = _FakeAuthRepository();
    cubit = SessionCubit(
      watchSessionExpired: WatchSessionExpiredUseCase(repo),
      signOut: SignOutUseCase(repo),
    );
  });

  test('starts as SessionActive', () async {
    expect(cubit.state, isA<SessionActive>());
    await cubit.close();
  });

  test('emits SessionExpired when the use case stream fires', () async {
    final emitted = <SessionState>[];
    final sub = cubit.stream.listen(emitted.add);

    repo.emitExpired();
    await Future<void>.delayed(Duration.zero);

    expect(emitted, [isA<SessionExpired>()]);
    expect(cubit.state, isA<SessionExpired>());
    await sub.cancel();
    await cubit.close();
  });

  test('signOut() calls the use case and emits SessionSignedOut', () async {
    final emitted = <SessionState>[];
    final sub = cubit.stream.listen(emitted.add);

    await cubit.signOut();
    await Future<void>.delayed(Duration.zero);

    expect(repo.signOutCallCount, 1);
    expect(emitted, [isA<SessionSignedOut>()]);
    expect(cubit.state, isA<SessionSignedOut>());
    await sub.cancel();
    await cubit.close();
  });

  test('does not emit after close', () async {
    final emitted = <SessionState>[];
    final sub = cubit.stream.listen(emitted.add);
    await cubit.close();

    repo.emitExpired();
    await Future<void>.delayed(Duration.zero);

    expect(emitted, isEmpty);
    await sub.cancel();
  });

  test('does not emit after close when signOut() is called', () async {
    final emitted = <SessionState>[];
    final sub = cubit.stream.listen(emitted.add);
    await cubit.close();

    await cubit.signOut();

    expect(emitted, isEmpty);
    await sub.cancel();
  });
}
