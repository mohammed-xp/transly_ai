import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../l10n/app_localizations.dart';

/// Bottom input dock with three input modes. Keyboard is the active mode; Voice
/// and Camera navigate to their screens (design `02 · Translate`).
class InputDock extends StatelessWidget {
  const InputDock({super.key, required this.isDark});

  final bool isDark;

  /// Design bottom margin (28) — grown when the device's bottom inset
  /// (gesture bar / home indicator) would otherwise overlap the dock.
  static double _bottomMargin(BuildContext context) => math.max(
        AppDimens.space3XL - 4,
        MediaQuery.viewPaddingOf(context).bottom + AppDimens.spaceM - 2,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      margin: EdgeInsets.fromLTRB(
        AppDimens.spaceL,
        AppDimens.spaceM - 2,
        AppDimens.spaceL,
        _bottomMargin(context),
      ),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusDock),
        border: Border.all(color: border),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: AppColors.dockShadowLight,
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _DockTab(
              isDark: isDark,
              icon: Icons.keyboard_alt_outlined,
              label: l10n.translateDockKeyboard,
              active: true,
              onTap: null, // already the active input mode
            ),
          ),
          Expanded(
            child: _DockTab(
              isDark: isDark,
              icon: Icons.mic_none_rounded,
              label: l10n.translateDockVoice,
              active: false,
              onTap: () => context.goNamed(AppRoutes.conversationName),
            ),
          ),
          Expanded(
            child: _DockTab(
              isDark: isDark,
              icon: Icons.photo_camera_outlined,
              label: l10n.translateDockCamera,
              active: false,
              onTap: () => context.goNamed(AppRoutes.cameraScanName),
            ),
          ),
        ],
      ),
    );
  }
}

class _DockTab extends StatelessWidget {
  const _DockTab({
    required this.isDark,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final bool isDark;
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final coral = isDark ? AppColors.accentDark : AppColors.primary;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final color = active ? coral : muted;
    final radius = BorderRadius.circular(AppDimens.radiusChipL);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.spaceS),
          child: Column(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
