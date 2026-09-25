sealed class SplashState {
  const SplashState();
}

class SplashInitializing extends SplashState {
  const SplashInitializing();
}

class SplashReady extends SplashState {
  const SplashReady({required this.isAuthenticated});

  final bool isAuthenticated;
}
