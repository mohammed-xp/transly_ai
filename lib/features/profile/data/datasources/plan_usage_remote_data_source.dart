import '../models/plan_usage_model.dart';

abstract class PlanUsageRemoteDataSource {
  Future<PlanUsageModel> getPlanUsage();
}
