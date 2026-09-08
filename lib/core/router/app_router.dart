import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/camera_scan/presentation/screens/camera_scan_screen.dart';
import '../../features/conversation/presentation/screens/conversation_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/translate/presentation/screens/translate_screen.dart';
import '../../features/translate/presentation/screens/translate_shell.dart';
import '../../features/translate/presentation/widgets/input_dock.dart';
import 'app_routes.dart';

/// App navigation. Splash, onboarding, sign-in and the translate shell (its
/// three input modes: keyboard/`/translate`, voice/`/conversation`,
/// camera/`/camera-scan`) render real screens; history and settings render
/// themed placeholders until their features are built.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: AppRoutes.splashName,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: AppRoutes.onboardingName,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.signIn,
      name: AppRoutes.signInName,
      builder: (context, state) => const SignInScreen(),
    ),
    translateShellRoute,
    GoRoute(
      path: AppRoutes.history,
      name: AppRoutes.historyName,
      builder: (context, state) => const _PlaceholderPage('History'),
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: AppRoutes.settingsName,
      builder: (context, state) => const _PlaceholderPage('Settings'),
    ),
  ],
);

/// The translate feature's three input modes (Keyboard/Voice/Camera), kept
/// on one persistent shell (header + language bar + input dock) via
/// [StatefulShellRoute.indexedStack] — switching modes updates only the
/// active branch, so `TranslateShell`'s `BlocProvider<TranslateCubit>`
/// survives the switch instead of being torn down and recreated. Branches are
/// built from [TranslateInputMode.values] so the enum and the branch order
/// can never drift apart. Hoisted to a top-level constant so tests can exercise
/// the exact route the app ships, not a copy that could diverge from it.
final RouteBase translateShellRoute = StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) => TranslateShell(
    currentMode: TranslateInputMode.values[navigationShell.currentIndex],
    onModeSelected: (mode) => navigationShell.goBranch(mode.index),
    child: navigationShell,
  ),
  branches: [
    for (final mode in TranslateInputMode.values)
      StatefulShellBranch(routes: [_translateBranchRoute(mode)]),
  ],
);

GoRoute _translateBranchRoute(TranslateInputMode mode) => switch (mode) {
  TranslateInputMode.keyboard => GoRoute(
    path: AppRoutes.translate,
    name: AppRoutes.translateName,
    builder: (context, state) => const TranslateScreen(),
  ),
  TranslateInputMode.voice => GoRoute(
    path: AppRoutes.conversation,
    name: AppRoutes.conversationName,
    builder: (context, state) => const ConversationScreen(),
  ),
  TranslateInputMode.camera => GoRoute(
    path: AppRoutes.cameraScan,
    name: AppRoutes.cameraScanName,
    builder: (context, state) => const CameraScanScreen(),
  ),
};

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(
        child: Text(label, style: Theme.of(context).textTheme.headlineLarge),
      ),
    );
  }
}
