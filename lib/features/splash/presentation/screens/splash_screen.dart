import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/decorative_blob.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';
import '../widgets/splash_spinner.dart';
import '../widgets/transly_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<SplashCubit>()..checkAuthStatus(),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatefulWidget {
  const _SplashView();

  @override
  State<_SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<_SplashView>
    with TickerProviderStateMixin {
  late final AnimationController _spin; // continuous spinner rotation
  late final AnimationController _entrance; // one-shot logo/text entrance
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.96,
      end: 1,
    ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _spin.dispose();
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;

    return BlocListener<SplashCubit, SplashState>(
      listenWhen: (_, current) => current is SplashReady,
      listener: (context, state) {
        if (state case SplashReady(:final isAuthenticated)) {
          context.goNamed(
            isAuthenticated ? AppRoutes.homeName : AppRoutes.onboardingName,
          );
        }
      },
      child: Scaffold(
        backgroundColor: c.screenBackground,
        body: Stack(
          children: [
            // Decorative coral glows.
            DecorativeBlob(
              isDark ? AppColors.accentDark : AppColors.primary,
              opacity: isDark ? 0.40 : 0.10,
              diameter: isDark ? 320 : 300,
              top: isDark ? -130 : -120,
              right: isDark ? -100 : -90,
            ),
            DecorativeBlob(
              isDark ? AppColors.deep : AppColors.primary,
              opacity: isDark ? 0.22 : 0.08,
              diameter: isDark ? 300 : 280,
              bottom: isDark ? -120 : -110,
              left: isDark ? -100 : -90,
            ),

            // Logo + wordmark + tagline.
            Center(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const TranslyLogo(),
                      const SizedBox(height: 24),
                      Text.rich(
                        TextSpan(
                          text: 'Transly',
                          children: [
                            TextSpan(
                              text: ' AI',
                              style: TextStyle(color: c.coralAccent),
                            ),
                          ],
                        ),
                        style: textTheme.displayLarge?.copyWith(
                          fontSize: 34,
                          color: c.ink,
                          letterSpacing: -0.34,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.splashTagline,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          color: c.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Spinner + caption pinned near the bottom.
            Positioned(
              left: 0,
              right: 0,
              bottom: 70,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RotationTransition(
                    turns: _spin,
                    child: SplashSpinner(
                      trackColor: c.spinnerTrack,
                      activeColor: c.coral,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.splashPoweredBy,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: c.iconLine,
                      letterSpacing: 0.48,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
