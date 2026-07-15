import 'package:flutter_bloc/flutter_bloc.dart';

import 'splash_state.dart';

/// Owns the splash timing. Presentation-only for now: there is no real bootstrap
/// work yet, so it holds the branded screen for a minimum duration and then
/// signals [SplashReady]. When real startup work appears (permissions, cached
/// prefs, ML-model warmup) this gains a use-case dependency.
class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(const SplashInitializing());

  /// Minimum time the splash stays visible before navigating onward.
  /// Public so tests advance the clock against the same source of truth.
  static const Duration minSplashDuration = Duration(seconds: 5);

  /// Runs the (currently timing-only) startup sequence, then emits [SplashReady].
  Future<void> start() async {
    await Future<void>.delayed(minSplashDuration);
    if (!isClosed) emit(const SplashReady());
  }
}
