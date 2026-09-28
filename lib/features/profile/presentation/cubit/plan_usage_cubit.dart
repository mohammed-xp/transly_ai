import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_plan_usage_usecase.dart';
import 'plan_usage_state.dart';

class PlanUsageCubit extends Cubit<PlanUsageState> {
  PlanUsageCubit({required GetPlanUsageUseCase getPlanUsage})
    : _getPlanUsage = getPlanUsage,
      super(const PlanUsageInitial());

  final GetPlanUsageUseCase _getPlanUsage;

  Future<void> loadUsage() async {
    emit(const PlanUsageLoading());
    final result = await _getPlanUsage();
    if (isClosed) return;
    emit(
      result.when<PlanUsageState>(
        success: PlanUsageLoaded.new,
        failure: PlanUsageFailed.new,
      ),
    );
  }
}
