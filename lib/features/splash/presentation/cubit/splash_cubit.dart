import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/usecases/get_cached_user_use_case.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit({required GetCachedUserUseCase getCachedUserUseCase})
    : _getCachedUser = getCachedUserUseCase,
      super(const SplashInitializing());

  final GetCachedUserUseCase _getCachedUser;

  static const Duration minSplashDuration = Duration(seconds: 5);

  Future<void> checkAuthStatus() async {
    final result = _getCachedUser();
    await Future<void>.delayed(minSplashDuration);
    if (isClosed) return;
    emit(
      SplashReady(
        isAuthenticated: result.when(
          success: (_) => true,
          failure: (_) => false,
        ),
      ),
    );
  }
}
