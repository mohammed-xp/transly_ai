import '../../../../core/errors/failure.dart';
import '../../domain/entities/plan_usage_entity.dart';

sealed class PlanUsageState {
  const PlanUsageState();
}

class PlanUsageInitial extends PlanUsageState {
  const PlanUsageInitial();
}

class PlanUsageLoading extends PlanUsageState {
  const PlanUsageLoading();
}

class PlanUsageLoaded extends PlanUsageState {
  const PlanUsageLoaded(this.usage);

  final PlanUsageEntity usage;
}

class PlanUsageFailed extends PlanUsageState {
  const PlanUsageFailed(this.failure);

  final Failure failure;
}
