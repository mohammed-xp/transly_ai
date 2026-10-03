import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/profile/domain/entities/plan_usage_entity.dart';
import 'package:transly_ai/features/profile/domain/repos/plan_usage_repo.dart';

class FakePlanUsageRepo implements PlanUsageRepo {
  FakePlanUsageRepo(this.result, {this.cachedPlan});

  ApiResult<PlanUsageEntity> result;
  final String? cachedPlan;
  int calls = 0;

  @override
  Future<ApiResult<PlanUsageEntity>> getPlanUsage() async {
    calls++;
    return result;
  }

  @override
  String? getCachedPlan() => cachedPlan;
}

const testProPlan = 'pro_monthly';

/// 3,500 of the free plan's 5,000 daily characters: the design's 70% / 30%.
final testFreeUsage = PlanUsageEntity(
  plan: PlanUsageEntity.freePlan,
  charactersLimit: 5000,
  charactersUsed: 3500,
  resetsAt: DateTime.utc(2026, 9, 29),
);

final testProUsage = PlanUsageEntity(
  plan: testProPlan,
  charactersLimit: 500000,
  charactersUsed: 3500,
  resetsAt: DateTime.utc(2026, 9, 29),
);
