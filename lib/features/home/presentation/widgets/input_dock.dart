import '../../../../core/constants/app_icons.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';

/// The three input modes the home shell can display. Declaration order is
/// the `IndexedStack` child order in `HomeShell`.
enum TranslateInputMode { keyboard, voice, camera }

extension TranslateInputModeLabel on TranslateInputMode {
  /// The mode's name, as its dock tab and the shell header show it.
  String label(AppLocalizations l10n) => switch (this) {
    TranslateInputMode.keyboard => l10n.translateDockKeyboard,
    TranslateInputMode.voice => l10n.translateDockVoice,
    TranslateInputMode.camera => l10n.translateDockCamera,
  };
}

/// Bottom input-mode dock (design `02 · Translate`). Stateless —
/// [currentMode] marks the active tab and [onModeSelected] fires when another
/// tab is tapped; the active tab stays inert. Owned by `HomeShell`, which
/// keeps it mounted while the content above it swaps.
///
/// A [voiceTab] replaces the plain Voice tab with one that rises
/// [voiceTabRaise] above the dock (design `Conversation v2`); the dock then
/// reserves that height so the raised part stays tappable.
class InputDock extends StatelessWidget {
  const InputDock({
    super.key,
    required this.currentMode,
    required this.onModeSelected,
    this.voiceTab,
    this.voiceTabRaise = 0,
  });

  final TranslateInputMode currentMode;
  final ValueChanged<TranslateInputMode> onModeSelected;
  final Widget? voiceTab;

  /// How far [voiceTab] reaches above the top of the tab row.
  final double voiceTabRaise;

  static const double _padding = 6;
  static const double _border = 1;
  static const double _topMargin = AppDimens.spaceM - 2;

  /// Design bottom margin (28) — grown when the device's bottom inset
  /// (gesture bar / home indicator) would otherwise overlap the dock.
  static double _bottomMargin(BuildContext context) => math.max(
    AppDimens.space3XL - 4,
    MediaQuery.viewPaddingOf(context).bottom + AppDimens.spaceM - 2,
  );

  @override
  Widget build(BuildContext context) {
    final voiceTab = this.voiceTab;
    if (voiceTab == null) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          AppDimens.spaceL,
          _topMargin,
          AppDimens.spaceL,
          _bottomMargin(context),
        ),
        child: _dock(context),
      );
    }

    // The dock sits [voiceTabRaise] below the content above it, and the
    // raised tab reaches up into that gap from the top of the tab row.
    const inset = _padding + _border;
    final overhang = math.max(0.0, voiceTabRaise - inset);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimens.spaceL,
        voiceTabRaise - overhang,
        AppDimens.spaceL,
        _bottomMargin(context),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: overhang),
            child: _dock(context),
          ),
          Positioned(
            top: 0,
            left: inset,
            right: inset,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Expanded(child: Center(child: voiceTab)),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dock(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.palette;

    return Container(
      padding: const EdgeInsets.all(_padding),
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
              icon: AppIcons.keyboard,
              label: TranslateInputMode.keyboard.label(l10n),
              active: currentMode == TranslateInputMode.keyboard,
              onTap: currentMode == TranslateInputMode.keyboard
                  ? null
                  : () => onModeSelected(TranslateInputMode.keyboard),
            ),
          ),
          Expanded(
            child: voiceTab != null
                ? const SizedBox.shrink()
                : _DockTab(
                    icon: AppIcons.mic,
                    label: TranslateInputMode.voice.label(l10n),
                    active: currentMode == TranslateInputMode.voice,
                    onTap: currentMode == TranslateInputMode.voice
                        ? null
                        : () => onModeSelected(TranslateInputMode.voice),
                  ),
          ),
          Expanded(
            child: _DockTab(
              icon: AppIcons.camera,
              label: TranslateInputMode.camera.label(l10n),
              active: currentMode == TranslateInputMode.camera,
              onTap: currentMode == TranslateInputMode.camera
                  ? null
                  : () => onModeSelected(TranslateInputMode.camera),
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

  /// One of the [AppIcons].
  final String icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;
    final color = active ? c.coral : c.textMuted;
    final radius = BorderRadius.circular(AppDimens.radiusChipL);

    return Semantics(
      selected: active,
      button: !active,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.spaceS),
            child: Column(
              children: [
                AppSvgIcon(icon, size: 22, color: color),
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
      ),
    );
  }
}
