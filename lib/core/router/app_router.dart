import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import 'app_routes.dart';

// Placeholder pages — replaced with real screens later
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(label)),
        body: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
      );
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const _PlaceholderPage('Onboarding'),
    ),
    GoRoute(
      path: AppRoutes.translate,
      name: 'translate',
      builder: (context, state) => const _PlaceholderPage('Translate'),
    ),
    GoRoute(
      path: AppRoutes.conversation,
      name: 'conversation',
      builder: (context, state) => const _PlaceholderPage('Conversation'),
    ),
    GoRoute(
      path: AppRoutes.cameraScan,
      name: 'camera_scan',
      builder: (context, state) => const _PlaceholderPage('Camera Scan'),
    ),
    GoRoute(
      path: AppRoutes.history,
      name: 'history',
      builder: (context, state) => const _PlaceholderPage('History'),
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      builder: (context, state) => const _PlaceholderPage('Settings'),
    ),
  ],
);
