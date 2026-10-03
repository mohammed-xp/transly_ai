import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/core/domain/usecases/get_cached_user_use_case.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/home/presentation/cubit/home_cubit.dart';
import 'package:transly_ai/features/home/presentation/cubit/home_state.dart';
import 'package:transly_ai/features/profile/domain/entities/plan_usage_entity.dart';
import 'package:transly_ai/features/profile/domain/usecases/get_cached_plan_usecase.dart';
import 'package:transly_ai/features/profile/domain/usecases/get_plan_usage_usecase.dart';

import '../../../../helpers/fake_plan_usage_repo.dart';
import '../../../../helpers/fake_user_repo.dart';

void main() {
  HomeCubit buildCubit(FakeUserRepo repo, {FakePlanUsageRepo? planRepo}) {
    final plans =
        planRepo ?? FakePlanUsageRepo(ApiResult.success(testFreeUsage));
    return HomeCubit(
      getCachedUser: GetCachedUserUseCase(repo),
      getCachedPlan: GetCachedPlanUseCase(plans),
      getPlanUsage: GetPlanUsageUseCase(plans),
    );
  }

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

  test('starts as Pro when the cached plan is a paid one', () {
    final cubit = buildCubit(
      FakeUserRepo(testUser),
      planRepo: FakePlanUsageRepo(
        ApiResult.success(testProUsage),
        cachedPlan: testProPlan,
      ),
    );
    addTearDown(cubit.close);

    expect(cubit.state.isPro, isTrue);
  });

  test('starts as free when the cached plan is the free one', () {
    final cubit = buildCubit(
      FakeUserRepo(testUser),
      planRepo: FakePlanUsageRepo(
        ApiResult.success(testFreeUsage),
        cachedPlan: PlanUsageEntity.freePlan,
      ),
    );
    addTearDown(cubit.close);

    expect(cubit.state.isPro, isFalse);
  });

  test('starts as free when no plan is cached', () {
    final cubit = buildCubit(FakeUserRepo(testUser));
    addTearDown(cubit.close);

    expect(cubit.state.isPro, isFalse);
  });

  test(
    'refreshPlan switches to Pro when the server reports a paid plan',
    () async {
      final cubit = buildCubit(
        FakeUserRepo(testUser),
        planRepo: FakePlanUsageRepo(ApiResult.success(testProUsage)),
      );
      addTearDown(cubit.close);

      await cubit.refreshPlan();

      expect(cubit.state.isPro, isTrue);
    },
  );

  test('refreshPlan drops back to free when the paid plan has ended', () async {
    final cubit = buildCubit(
      FakeUserRepo(testUser),
      planRepo: FakePlanUsageRepo(
        ApiResult.success(testFreeUsage),
        cachedPlan: testProPlan,
      ),
    );
    addTearDown(cubit.close);

    await cubit.refreshPlan();

    expect(cubit.state.isPro, isFalse);
  });

  test('refreshPlan keeps the cached plan when the fetch fails', () async {
    final cubit = buildCubit(
      FakeUserRepo(testUser),
      planRepo: FakePlanUsageRepo(
        const ApiResult.failure(NetworkFailure()),
        cachedPlan: testProPlan,
      ),
    );
    addTearDown(cubit.close);

    await cubit.refreshPlan();

    expect(cubit.state.isPro, isTrue);
  });

  test('swapLanguages keeps the plan', () async {
    final cubit = buildCubit(
      FakeUserRepo(testUser),
      planRepo: FakePlanUsageRepo(ApiResult.success(testProUsage)),
    );
    addTearDown(cubit.close);
    await cubit.refreshPlan();

    cubit.swapLanguages();

    expect(cubit.state.isPro, isTrue);
  });

  test('refreshPlan keeps the user and the language pair', () async {
    final cubit = buildCubit(
      FakeUserRepo(testUser),
      planRepo: FakePlanUsageRepo(ApiResult.success(testProUsage)),
    );
    addTearDown(cubit.close);
    cubit.swapLanguages();

    await cubit.refreshPlan();

    expect(cubit.state.user, same(testUser));
    expect(cubit.state.from, LanguageEntity.defaultTarget);
    expect(cubit.state.to, LanguageEntity.defaultSource);
  });

  test('does not emit once closed while a refresh is in flight', () async {
    final cubit = buildCubit(
      FakeUserRepo(testUser),
      planRepo: FakePlanUsageRepo(ApiResult.success(testProUsage)),
    );
    final states = <HomeState>[];
    final subscription = cubit.stream.listen(states.add);

    final refresh = cubit.refreshPlan();
    final closing = cubit.close();

    await expectLater(refresh, completes);
    await closing;
    await subscription.cancel();
    expect(states, isEmpty);
  });
}
