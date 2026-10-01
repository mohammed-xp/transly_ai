import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/decorative_blob.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/onboarding_logo.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) => const _OnboardingView();
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance; // one-shot fade + slide-up
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  /// Full-bleed coral background (light). Design: `168deg #FF7A4D → #F5421C@52%
  /// → #D5300F`.
  static const LinearGradient _lightBackground = LinearGradient(
    begin: Alignment(-0.15, -1),
    end: Alignment(0.15, 1),
    colors: [
      AppColors.gradientStart,
      AppColors.deep,
      AppColors.gradientDeepEnd,
    ],
    stops: [0, 0.52, 1],
  );

  static const double _hPadding = 30; // screen h-padding (design)

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    final subtitleColor = Colors.white.withValues(alpha: isDark ? 0.86 : 0.92);
    final captionColor = Colors.white.withValues(alpha: isDark ? 0.5 : 0.66);

    return Scaffold(
      body: Stack(
        children: [
          // Background wash.
          Positioned.fill(
            child: isDark
                ? const ColoredBox(color: AppColors.backgroundDark)
                : const DecoratedBox(
                    decoration: BoxDecoration(gradient: _lightBackground),
                  ),
          ),

          // Decorations: radial coral glows (dark) or flat white circles (light).
          if (isDark) ...[
            const DecorativeBlob(
              AppColors.primary,
              opacity: 0.5,
              diameter: 360,
              top: -140,
              right: -120,
            ),
            const DecorativeBlob(
              AppColors.deep,
              opacity: 0.28,
              diameter: 300,
              top: 160,
              left: -130,
            ),
          ] else ...[
            const _SoftCircle(
              diameter: 320,
              opacity: 0.10,
              top: -120,
              right: -80,
            ),
            const _SoftCircle(
              diameter: 260,
              opacity: 0.07,
              top: 90,
              left: -110,
            ),
          ],

          // Content. Bottom-anchored via the Spacer on tall screens; scrolls
          // instead of overflowing on short ones (ConstrainedBox + IntrinsicHeight).
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          _hPadding,
                          44,
                          _hPadding,
                          32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeTransition(
                              opacity: _fade,
                              child: _LanguageChips(isDark: isDark),
                            ),
                            const Spacer(),
                            SlideTransition(
                              position: _slide,
                              child: FadeTransition(
                                opacity: _fade,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const OnboardingLogo(),
                                    const SizedBox(height: 26),
                                    _Wordmark(
                                      isDark: isDark,
                                      textTheme: textTheme,
                                    ),
                                    const SizedBox(height: 14),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 280,
                                      ),
                                      child: Text(
                                        l10n.onboardingSubtitle,
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontSize: 17,
                                          height: 1.5,
                                          color: subtitleColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      l10n.onboardingCaption,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: captionColor,
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    SizedBox(
                                      width: double.infinity,
                                      child: _GetStartedButton(
                                        isDark: isDark,
                                        label: l10n.onboardingGetStarted,
                                        textTheme: textTheme,
                                        onPressed: () => context.goNamed(
                                          AppRoutes.signInName,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    _SignInRow(
                                      isDark: isDark,
                                      textTheme: textTheme,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A flat, translucent-white circle behind the light-mode hero. (Dark mode uses
/// the radial [DecorativeBlob] instead, hence this stays onboarding-local.)
class _SoftCircle extends StatelessWidget {
  const _SoftCircle({
    required this.diameter,
    required this.opacity,
    this.top,
    this.left,
    this.right,
  });

  final double diameter;
  final double opacity;
  final double? top;
  final double? left;
  final double? right;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: opacity),
          ),
        ),
      ),
    );
  }
}

/// Wrap of floating language pills. The final `+85` pill is coral-tinted in dark.
class _LanguageChips extends StatelessWidget {
  const _LanguageChips({required this.isDark});

  final bool isDark;

  static const List<String> _languages = [
    'English',
    'العربية',
    'Español',
    '日本語',
    'Français',
  ];

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge;
    return Wrap(
      spacing: AppDimens.spaceS,
      runSpacing: AppDimens.spaceS,
      children: [
        for (final lang in _languages) _chip(lang, style: labelStyle),
        _chip('+85', style: labelStyle, highlight: true),
      ],
    );
  }

  Widget _chip(String text, {TextStyle? style, bool highlight = false}) {
    late final Color bg;
    late final Color fg;
    Border? border;
    var weight = FontWeight.w500;

    if (isDark) {
      if (highlight) {
        bg = AppColors.primary.withValues(alpha: 0.18);
        fg = AppColors.accentDark2;
        border = Border.all(color: AppColors.primary.withValues(alpha: 0.3));
        weight = FontWeight.w600;
      } else {
        bg = Colors.white.withValues(alpha: 0.08);
        fg = Colors.white;
        border = Border.all(color: Colors.white.withValues(alpha: 0.08));
      }
    } else {
      bg = Colors.white.withValues(alpha: 0.16);
      fg = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: border,
      ),
      child: Text(
        text,
        style: style?.copyWith(fontWeight: weight, color: fg),
      ),
    );
  }
}

/// "Transly AI" wordmark — brand name, not localized.
class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.isDark, required this.textTheme});

  final bool isDark;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final base = textTheme.displayLarge?.copyWith(
      color: Colors.white,
      height: 1.05,
    );
    return Text.rich(
      TextSpan(
        text: 'Transly',
        style: base,
        children: [
          TextSpan(
            text: ' AI',
            style: base?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: isDark ? 0.5 : 0.62),
            ),
          ),
        ],
      ),
    );
  }
}

/// Primary call-to-action. Light: white fill + coral label. Dark: gradient fill
/// + white label. The trailing arrow points in the reading direction (flips RTL).
class _GetStartedButton extends StatelessWidget {
  const _GetStartedButton({
    required this.isDark,
    required this.label,
    required this.textTheme,
    required this.onPressed,
  });

  final bool isDark;
  final String label;
  final TextTheme textTheme;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final foreground = isDark ? Colors.white : AppColors.deep;
    final radius = BorderRadius.circular(AppDimens.radiusButton);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? null : Colors.white,
        gradient: isDark ? AppColors.brandGradient : null,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.deep.withValues(alpha: 0.4)
                : AppColors.brandShadow.withValues(alpha: 0.28),
            blurRadius: isDark ? 30 : 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: SizedBox(
            height: AppDimens.buttonHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: textTheme.titleLarge?.copyWith(color: foreground),
                ),
                const SizedBox(width: AppDimens.spaceS),
                Icon(
                  isRtl
                      ? Icons.arrow_back_rounded
                      : Icons.arrow_forward_rounded,
                  size: AppDimens.iconS + 2,
                  color: foreground,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Have an account? Sign in" — routes to the sign-in screen.
class _SignInRow extends StatelessWidget {
  const _SignInRow({required this.isDark, required this.textTheme});

  final bool isDark;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final promptColor = Colors.white.withValues(alpha: isDark ? 0.55 : 0.8);
    final linkColor = isDark ? AppColors.accentDark2 : Colors.white;

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppDimens.spaceXS,
        children: [
          Text(
            l10n.onboardingHaveAccount,
            style: textTheme.bodySmall?.copyWith(color: promptColor),
          ),
          GestureDetector(
            onTap: () => context.pushNamed(AppRoutes.signInName),
            child: Text(
              l10n.onboardingSignIn,
              style: textTheme.bodySmall?.copyWith(
                color: linkColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
