import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/screens/splash_screen.dart';
import 'app_routes.dart';

/// App navigation. Each route currently renders a themed placeholder so the
/// app runs; real screens replace these placeholders as features are built.
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
      builder: (context, state) => const _PlaceholderPage('Onboarding'),
    ),
    GoRoute(
      path: AppRoutes.translate,
      name: AppRoutes.translateName,
      builder: (context, state) => const _PlaceholderPage('Translate'),
    ),
    GoRoute(
      path: AppRoutes.conversation,
      name: AppRoutes.conversationName,
      builder: (context, state) => const _PlaceholderPage('Conversation'),
    ),
    GoRoute(
      path: AppRoutes.cameraScan,
      name: AppRoutes.cameraScanName,
      builder: (context, state) => const _PlaceholderPage('Camera Scan'),
    ),
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
