import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/repos/logout_repo.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/session/session_manager.dart';
import 'package:transly_ai/features/auth/presentation/cubit/session_cubit.dart';
import 'package:transly_ai/features/auth/presentation/cubit/session_state.dart';

import '../../../../helpers/fake_logout_repo.dart';
import '../../../../helpers/session_cubit_factory.dart';

class _GatedLogoutRepo implements LogoutRepo {
  final gate = Completer<void>();

  @override
  Future<ApiResult<void>> logout() async {
    await gate.future;
    return const ApiResult.success(null);
  }
}

void main() {
  Future<List<SessionState>> statesOf(
    SessionCubit cubit,
    Future<void> Function() action,
  ) async {
    final states = <SessionState>[];
    final subscription = cubit.stream.listen(states.add);
    await action();
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();
    return states;
  }

  SessionCubit buildCubit(SessionManager session) {
    final cubit = buildSessionCubit(session: session);
    addTearDown(cubit.close);
    return cubit;
  }

  test('shows signing out before the session ends', () async {
    final cubit = buildCubit(SessionManager(FakeLogoutRepo()));

    final states = await statesOf(cubit, cubit.signOut);

    expect(states, [isA<SessionSigningOut>(), isA<SessionSignedOut>()]);
  });

  test('does nothing once the session has already ended', () async {
    final logoutRepo = FakeLogoutRepo();
    final session = SessionManager(logoutRepo);
    final cubit = buildCubit(session);
    await session.expire();
    await Future<void>.delayed(Duration.zero);

    final states = await statesOf(cubit, cubit.signOut);

    expect(states, isEmpty);
    expect(cubit.state, isA<SessionExpired>());
    expect(logoutRepo.calls, 1);
  });

  test('ends as expired when the session expires mid sign-out', () async {
    final logoutRepo = _GatedLogoutRepo();
    final session = SessionManager(logoutRepo);
    final cubit = buildCubit(session);

    final states = await statesOf(cubit, () async {
      final expiring = session.expire();
      await cubit.signOut();
      logoutRepo.gate.complete();
      await expiring;
    });

    expect(states, [isA<SessionSigningOut>(), isA<SessionExpired>()]);
  });
}
