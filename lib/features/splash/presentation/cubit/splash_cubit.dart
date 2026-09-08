import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/usecases/has_active_session_usecase.dart';
import 'splash_state.dart';

/// Owns the splash timing and the sign-in gate check. Holds the branded
/// screen for a minimum duration while checking, in parallel, whether a
/// session token is already persisted — then signals [SplashReady] with the
/// result so the screen can route straight to translate or to onboarding.
class SplashCubit extends Cubit<SplashState> {
  SplashCubit({required HasActiveSessionUseCase hasActiveSession})
    : _hasActiveSession = hasActiveSession,
      super(const SplashInitializing());

  final HasActiveSessionUseCase _hasActiveSession;

  /// Minimum time the splash stays visible before navigating onward.
  /// Public so tests advance the clock against the same source of truth.
  static const Duration minSplashDuration = Duration(seconds: 5);

  /// Runs the startup sequence — the session check runs concurrently with
  /// the minimum splash delay, not after it — then emits [SplashReady].
  Future<void> start() async {
    final sessionCheck = _hasActiveSession();
    await Future<void>.delayed(minSplashDuration);
    final result = await sessionCheck;
    if (isClosed) return;
    emit(
      SplashReady(
        isAuthenticated: result.when(
          success: (isActive) => isActive,
          failure: (_) => false,
        ),
      ),
    );
  }
}
