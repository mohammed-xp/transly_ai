import '../../../../core/result/api_result.dart';
import '../entities/plan_usage_entity.dart';
import '../repos/plan_usage_repo.dart';

class GetPlanUsageUseCase {
  const GetPlanUsageUseCase(this._repo);

  final PlanUsageRepo _repo;

  Future<ApiResult<PlanUsageEntity>> call() => _repo.getPlanUsage();
}
