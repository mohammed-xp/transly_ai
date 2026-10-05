import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/user_entity.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/session/session_manager.dart';
import 'package:transly_ai/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:transly_ai/features/auth/presentation/cubit/google_sign_in_cubit.dart';
import 'package:transly_ai/features/auth/presentation/cubit/google_sign_in_state.dart';

import '../../../../helpers/fake_auth_repo.dart';
import '../../../../helpers/fake_logout_repo.dart';

void main() {
  late SessionManager session;
  late List<SessionStatus> sessionEvents;

  setUp(() {
    session = SessionManager(FakeLogoutRepo());
    sessionEvents = [];
    final subscription = session.stream.listen(sessionEvents.add);
    addTearDown(subscription.cancel);
  });

  FakeAuthRepo repoWith(ApiResult<UserEntity?> googleResult) =>
      FakeAuthRepo(const ApiResult.success(null), googleResult: googleResult);

  GoogleSignInCubit buildCubit(FakeAuthRepo repo) {
    final cubit = GoogleSignInCubit(SignInWithGoogleUseCase(repo, session));
    addTearDown(cubit.close);
    return cubit;
  }

  Future<List<GoogleSignInState>> statesOf(
    GoogleSignInCubit cubit,
    Future<void> Function() action,
  ) async {
    final states = <GoogleSignInState>[];
    final subscription = cubit.stream.listen(states.add);
    await action();
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();
    return states;
  }

  final user = UserEntity(
    id: 'u1',
    email: 'ahmed@example.com',
    username: 'Ahmed Salem',
    createdAt: DateTime.utc(2026, 10),
  );

  test('signs in and starts the session', () async {
    final cubit = buildCubit(repoWith(ApiResult.success(user)));

    final states = await statesOf(cubit, cubit.signIn);

    expect(states, [isA<GoogleSignInLoading>(), isA<GoogleSignInSucceeded>()]);
    expect(sessionEvents, [SessionStatus.authenticated]);
  });

  test('goes back to idle, with no error, when the picker is closed', () async {
    final cubit = buildCubit(repoWith(const ApiResult.success(null)));

    final states = await statesOf(cubit, cubit.signIn);

    expect(states, [isA<GoogleSignInLoading>(), isA<GoogleSignInInitial>()]);
    expect(sessionEvents, isEmpty);
  });

  test('reports the failure and starts no session', () async {
    final cubit = buildCubit(
      repoWith(const ApiResult.failure(NetworkFailure())),
    );

    final states = await statesOf(cubit, cubit.signIn);

    expect(states.last, isA<GoogleSignInFailed>());
    expect((states.last as GoogleSignInFailed).failure, isA<NetworkFailure>());
    expect(sessionEvents, isEmpty);
  });

  test('ignores a second tap while a sign-in is in flight', () async {
    final repo = repoWith(ApiResult.success(user))..gate = Completer<void>();
    final cubit = buildCubit(repo);

    final first = cubit.signIn();
    await cubit.signIn();
    repo.gate!.complete();
    await first;

    expect(repo.googleSignIns, 1);
    expect(cubit.state, isA<GoogleSignInSucceeded>());
  });
}
