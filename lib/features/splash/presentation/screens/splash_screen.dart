import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/decorative_blob.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';
import '../widgets/splash_spinner.dart';
import '../widgets/transly_logo.dart';

/// Branded launch screen (design `00 · Splash`, light + dark). Shows the logo,
/// wordmark and tagline while [SplashCubit] runs startup, then routes onward.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SplashCubit>()..start(),
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
    _scale = Tween<double>(begin: 0.96, end: 1)
        .animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutBack));
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

    final background = isDark ? AppColors.backgroundDark : AppColors.surfaceLight;
    final inkColor = isDark ? AppColors.textPrimaryDark : AppColors.inkLight;
    final accentColor = isDark ? AppColors.accentDark2 : AppColors.primary;
    final taglineColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final spinnerTrack =
        isDark ? AppColors.borderDark : AppColors.spinnerTrackLight;
    final spinnerActive = isDark ? AppColors.accentDark : AppColors.primary;
    final poweredColor =
        isDark ? AppColors.iconLineDark : AppColors.captionMutedLight;

    return BlocListener<SplashCubit, SplashState>(
      listenWhen: (_, current) => current is SplashReady,
      listener: (context, _) => context.goNamed(AppRoutes.onboardingName),
      child: Scaffold(
        backgroundColor: background,
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
                              style: TextStyle(color: accentColor),
                            ),
                          ],
                        ),
                        style: textTheme.displayLarge?.copyWith(
                          fontSize: 34,
                          color: inkColor,
                          letterSpacing: -0.34,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.splashTagline,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          color: taglineColor,
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
                      trackColor: spinnerTrack,
                      activeColor: spinnerActive,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.splashPoweredBy,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: poweredColor,
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
