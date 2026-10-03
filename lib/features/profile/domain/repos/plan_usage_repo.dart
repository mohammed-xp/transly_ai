import '../../../../core/result/api_result.dart';
import '../entities/plan_usage_entity.dart';

abstract class PlanUsageRepo {
  Future<ApiResult<PlanUsageEntity>> getPlanUsage();

  /// The plan from the last successful [getPlanUsage] of the signed-in user,
  /// or null when there is none yet.
  String? getCachedPlan();
}
