import '../repos/plan_usage_repo.dart';

class GetCachedPlanUseCase {
  const GetCachedPlanUseCase(this._repo);

  final PlanUsageRepo _repo;

  String? call() => _repo.getCachedPlan();
}
