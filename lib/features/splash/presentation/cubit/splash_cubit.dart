import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/usecases/get_cached_user_use_case.dart';
import '../../../language_picker/domain/usecases/sync_languages_usecase.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit({
    required GetCachedUserUseCase getCachedUserUseCase,
    required SyncLanguagesUseCase syncLanguages,
  }) : _getCachedUser = getCachedUserUseCase,
       _syncLanguages = syncLanguages,
       super(const SplashInitializing());

  final GetCachedUserUseCase _getCachedUser;
  final SyncLanguagesUseCase _syncLanguages;

  static const Duration minSplashDuration = Duration(seconds: 2);

  /// A signed-in launch also refreshes the translation languages in the
  /// background. Startup doesn't wait for it, and a failed refresh keeps the
  /// cached list. Signed out, a rejected request would end a session that
  /// doesn't exist and bounce the user to sign-in.
  Future<void> checkAuthStatus() async {
    final isAuthenticated = _getCachedUser().when(
      success: (_) => true,
      failure: (_) => false,
    );
    if (isAuthenticated) unawaited(_syncLanguages());
    await Future<void>.delayed(minSplashDuration);
    if (isClosed) return;
    emit(SplashReady(isAuthenticated: isAuthenticated));
  }
}
