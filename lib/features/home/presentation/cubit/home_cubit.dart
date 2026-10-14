import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/domain/usecases/get_cached_user_use_case.dart';
import '../../../language_picker/domain/entities/language_pair.dart';
import '../../../language_picker/domain/usecases/get_saved_language_pair_usecase.dart';
import '../../../language_picker/domain/usecases/save_language_pair_usecase.dart';
import '../../../profile/domain/entities/plan_usage_entity.dart';
import '../../../profile/domain/usecases/get_cached_plan_usecase.dart';
import '../../../profile/domain/usecases/get_plan_usage_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required GetCachedUserUseCase getCachedUser,
    required GetCachedPlanUseCase getCachedPlan,
    required GetPlanUsageUseCase getPlanUsage,
    required GetSavedLanguagePairUseCase getSavedLanguagePair,
    required SaveLanguagePairUseCase saveLanguagePair,
  }) : _getPlanUsage = getPlanUsage,
       _saveLanguagePair = saveLanguagePair,
       super(
         HomeState.initial(
           user: getCachedUser().when(
             success: (user) => user,
             failure: (_) => null,
           ),
           isPro: PlanUsageEntity.isProPlan(getCachedPlan()),
           languages: getSavedLanguagePair(),
         ),
       );

  final GetPlanUsageUseCase _getPlanUsage;
  final SaveLanguagePairUseCase _saveLanguagePair;

  void swapLanguages() => _setPair(from: state.to, to: state.from);

  void setLanguages(LanguagePair pair) {
    if (pair.from == state.from && pair.to == state.to) return;
    _setPair(from: pair.from, to: pair.to);
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

  /// A pair that can't be saved still applies for this session; only the
  /// next launch falls back to the last saved one.
  void _setPair({required LanguageEntity from, required LanguageEntity to}) {
    emit(state.copyWith(from: from, to: to));
    unawaited(_saveLanguagePair((from: from, to: to)));
  }
}
