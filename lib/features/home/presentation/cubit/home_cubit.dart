import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/usecases/get_cached_user_use_case.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required GetCachedUserUseCase getCachedUser})
    : super(
        HomeState.initial(
          user: getCachedUser().when(
            success: (user) => user,
            failure: (_) => null,
          ),
        ),
      );

  void swapLanguages() {
    emit(state.copyWith(from: state.to, to: state.from));
  }
}
