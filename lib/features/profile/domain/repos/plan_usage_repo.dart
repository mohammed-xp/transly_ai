import '../../../../core/result/api_result.dart';
import '../entities/plan_usage_entity.dart';

abstract class PlanUsageRepo {
  Future<ApiResult<PlanUsageEntity>> getPlanUsage();
}
