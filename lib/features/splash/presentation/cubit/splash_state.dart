/// State for [SplashCubit]. Pure Dart — no Flutter imports (CLAUDE.md §B-3).
sealed class SplashState {
  const SplashState();
}

/// Startup work is in progress; the branded splash is showing.
class SplashInitializing extends SplashState {
  const SplashInitializing();
}

/// Startup finished; the screen should navigate onward.
class SplashReady extends SplashState {
  const SplashReady();
}
