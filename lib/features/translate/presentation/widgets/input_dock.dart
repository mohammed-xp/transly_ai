import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';

/// Bottom input dock with three input modes. Keyboard is the active mode; Voice
/// and Camera navigate to their screens (design `02 · Translate`).
class InputDock extends StatelessWidget {
  const InputDock({super.key});

  /// Design bottom margin (28) — grown when the device's bottom inset
  /// (gesture bar / home indicator) would otherwise overlap the dock.
  static double _bottomMargin(BuildContext context) => math.max(
        AppDimens.space3XL - 4,
        MediaQuery.viewPaddingOf(context).bottom + AppDimens.spaceM - 2,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.palette;

    return Container(
      margin: EdgeInsets.fromLTRB(
        AppDimens.spaceL,
        AppDimens.spaceM - 2,
        AppDimens.spaceL,
        _bottomMargin(context),
      ),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusDock),
        border: Border.all(color: c.border),
        boxShadow: c.dockShadow == null
            ? null
            : [
                BoxShadow(
                  color: c.dockShadow!,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _DockTab(
              icon: Icons.keyboard_alt_outlined,
              label: l10n.translateDockKeyboard,
              active: true,
              onTap: null, // already the active input mode
            ),
          ),
          Expanded(
            child: _DockTab(
              icon: Icons.mic_none_rounded,
              label: l10n.translateDockVoice,
              active: false,
              onTap: () => context.goNamed(AppRoutes.conversationName),
            ),
          ),
          Expanded(
            child: _DockTab(
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
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;
    final color = active ? c.coral : c.textMuted;
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
