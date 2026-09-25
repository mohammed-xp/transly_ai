import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState.initial());

  void swapLanguages() {
    emit(state.copyWith(from: state.to, to: state.from));
  }
}
