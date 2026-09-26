import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/usecases/get_cached_user_use_case.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:transly_ai/features/profile/presentation/cubit/profile_state.dart';

import '../../../../helpers/fake_user_repo.dart';

void main() {
  ProfileCubit buildCubit(FakeUserRepo repo) =>
      ProfileCubit(getCachedUser: GetCachedUserUseCase(repo));

  test('starts in ProfileInitial', () {
    final cubit = buildCubit(FakeUserRepo(testUser));
    addTearDown(cubit.close);

    expect(cubit.state, isA<ProfileInitial>());
  });

  test('loadProfile emits ProfileLoaded with the cached user', () {
    final cubit = buildCubit(FakeUserRepo(testUser));
    addTearDown(cubit.close);

    cubit.loadProfile();

    final state = cubit.state;
    expect(state, isA<ProfileLoaded>());
    expect((state as ProfileLoaded).user, same(testUser));
  });

  test('loadProfile emits ProfileFailed when no user is cached', () {
    final cubit = buildCubit(FakeUserRepo());
    addTearDown(cubit.close);

    cubit.loadProfile();

    final state = cubit.state;
    expect(state, isA<ProfileFailed>());
    expect((state as ProfileFailed).failure, isA<UnauthorizedFailure>());
  });
}
