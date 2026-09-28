import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/profile/domain/usecases/get_plan_usage_usecase.dart';
import 'package:transly_ai/features/profile/presentation/cubit/plan_usage_cubit.dart';
import 'package:transly_ai/features/profile/presentation/cubit/plan_usage_state.dart';

import '../../../../helpers/fake_plan_usage_repo.dart';

void main() {
  PlanUsageCubit buildCubit(FakePlanUsageRepo repo) =>
      PlanUsageCubit(getPlanUsage: GetPlanUsageUseCase(repo));

  Future<List<PlanUsageState>> statesOf(
    PlanUsageCubit cubit,
    Future<void> Function() action,
  ) async {
    final states = <PlanUsageState>[];
    final subscription = cubit.stream.listen(states.add);
    await action();
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();
    return states;
  }

  test('starts in PlanUsageInitial', () {
    final cubit = buildCubit(
      FakePlanUsageRepo(ApiResult.success(testFreeUsage)),
    );
    addTearDown(cubit.close);

    expect(cubit.state, isA<PlanUsageInitial>());
  });

  test('loadUsage emits Loading then Loaded with the usage', () async {
    final cubit = buildCubit(
      FakePlanUsageRepo(ApiResult.success(testFreeUsage)),
    );
    addTearDown(cubit.close);

    final states = await statesOf(cubit, cubit.loadUsage);

    expect(states, [isA<PlanUsageLoading>(), isA<PlanUsageLoaded>()]);
    expect((states.last as PlanUsageLoaded).usage, same(testFreeUsage));
  });

  test('loadUsage emits Loading then Failed with the failure', () async {
    final cubit = buildCubit(
      FakePlanUsageRepo(const ApiResult.failure(NetworkFailure())),
    );
    addTearDown(cubit.close);

    final states = await statesOf(cubit, cubit.loadUsage);

    expect(states, [isA<PlanUsageLoading>(), isA<PlanUsageFailed>()]);
    expect((states.last as PlanUsageFailed).failure, isA<NetworkFailure>());
  });

  test('loadUsage after a failure fetches again and recovers', () async {
    final repo = FakePlanUsageRepo(const ApiResult.failure(NetworkFailure()));
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);
    await cubit.loadUsage();

    repo.result = ApiResult.success(testFreeUsage);
    await cubit.loadUsage();

    expect(repo.calls, 2);
    expect(cubit.state, isA<PlanUsageLoaded>());
  });

  test('does not emit once closed while a load is in flight', () async {
    final cubit = buildCubit(
      FakePlanUsageRepo(ApiResult.success(testFreeUsage)),
    );

    final load = cubit.loadUsage();
    final closing = cubit.close();

    await expectLater(load, completes);
    await closing;
  });
}
