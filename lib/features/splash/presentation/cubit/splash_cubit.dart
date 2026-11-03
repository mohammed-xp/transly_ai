import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/usecases/get_cached_user_use_case.dart';
import '../../../../core/domain/usecases/sync_analytics_user_usecase.dart';
import '../../../language_picker/domain/usecases/sync_languages_usecase.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit({
    required GetCachedUserUseCase getCachedUserUseCase,
    required SyncLanguagesUseCase syncLanguages,
    required SyncAnalyticsUserUseCase syncAnalyticsUser,
  }) : _getCachedUser = getCachedUserUseCase,
       _syncLanguages = syncLanguages,
       _syncAnalyticsUser = syncAnalyticsUser,
       super(const SplashInitializing());

  final GetCachedUserUseCase _getCachedUser;
  final SyncLanguagesUseCase _syncLanguages;
  final SyncAnalyticsUserUseCase _syncAnalyticsUser;

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
    unawaited(_syncAnalyticsUser());
    if (isAuthenticated) unawaited(_syncLanguages());
    await Future<void>.delayed(minSplashDuration);
    if (isClosed) return;
    emit(SplashReady(isAuthenticated: isAuthenticated));
  }
}
