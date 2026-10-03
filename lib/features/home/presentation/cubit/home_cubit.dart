import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/usecases/get_cached_user_use_case.dart';
import '../../../profile/domain/entities/plan_usage_entity.dart';
import '../../../profile/domain/usecases/get_cached_plan_usecase.dart';
import '../../../profile/domain/usecases/get_plan_usage_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required GetCachedUserUseCase getCachedUser,
    required GetCachedPlanUseCase getCachedPlan,
    required GetPlanUsageUseCase getPlanUsage,
  }) : _getPlanUsage = getPlanUsage,
       super(
         HomeState.initial(
           user: getCachedUser().when(
             success: (user) => user,
             failure: (_) => null,
           ),
           isPro: PlanUsageEntity.isProPlan(getCachedPlan()),
         ),
       );

  final GetPlanUsageUseCase _getPlanUsage;

  void swapLanguages() {
    emit(state.copyWith(from: state.to, to: state.from));
  }

  /// A failed fetch keeps the last known plan: the badge has no error state,
  /// and the cached plan is the best answer while offline.
  Future<void> refreshPlan() async {
    final result = await _getPlanUsage();
    if (isClosed) return;
    result.when(
      success: (usage) => emit(state.copyWith(isPro: usage.isPro)),
      failure: (_) {},
    );
  }
}
