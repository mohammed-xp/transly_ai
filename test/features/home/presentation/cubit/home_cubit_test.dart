import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/core/domain/usecases/get_cached_user_use_case.dart';
import 'package:transly_ai/features/home/presentation/cubit/home_cubit.dart';

import '../../../../helpers/fake_user_repo.dart';

void main() {
  HomeCubit buildCubit(FakeUserRepo repo) =>
      HomeCubit(getCachedUser: GetCachedUserUseCase(repo));

  test('exposes the cached user for the header avatar', () {
    final cubit = buildCubit(FakeUserRepo(testUser));
    addTearDown(cubit.close);

    expect(cubit.state.user, same(testUser));
  });

  test('user is null when none is cached', () {
    final cubit = buildCubit(FakeUserRepo());
    addTearDown(cubit.close);

    expect(cubit.state.user, isNull);
  });

  test('swapLanguages swaps the pair and keeps the user', () {
    final cubit = buildCubit(FakeUserRepo(testUser));
    addTearDown(cubit.close);

    cubit.swapLanguages();

    expect(cubit.state.from, LanguageEntity.defaultTarget);
    expect(cubit.state.to, LanguageEntity.defaultSource);
    expect(cubit.state.user, same(testUser));
  });
}
