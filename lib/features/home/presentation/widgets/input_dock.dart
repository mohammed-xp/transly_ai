import '../../../../core/constants/app_icons.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';

/// The three input modes the home shell can display. Declaration order is
/// the `ModeTransitionStack` child order in `HomeShell`.
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
/// A [voiceTab] stands over the plain Voice tab, rising [voiceTabRaise] above
/// the dock (design `Conversation v2`). It stays mounted to animate in and
/// out; while the Voice tab is open the dock reserves that height so the
/// raised part stays tappable, easing into it (design `Mode Transition`).
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

    // While the Voice tab is open the dock sits [voiceTabRaise] below the
    // content above it, and the raised tab reaches up into that gap from the
    // top of the tab row. Pinned to the dock, the raised tab holds still as
    // the gap eases open.
    const inset = _padding + _border;
    final overhang = math.max(0.0, voiceTabRaise - inset);
    final topPadding = voiceTabRaise - overhang;
    final raisedTab = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Expanded(child: Center(child: voiceTab)),
        const Spacer(),
      ],
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimens.spaceL,
        topPadding,
        AppDimens.spaceL,
        _bottomMargin(context),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(
          end: currentMode == TranslateInputMode.voice
              ? overhang
              : _topMargin - topPadding,
        ),
        duration: AppMotion.modeSwitch,
        curve: AppMotion.modeCurve,
        child: _dock(context),
        builder: (context, gap, dock) => Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.only(top: gap),
              child: dock,
            ),
            Positioned(
              top: gap - overhang,
              left: inset,
              right: inset,
              child: raisedTab,
            ),
          ],
        ),
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
            child: _DockTab(
              icon: AppIcons.mic,
              label: TranslateInputMode.voice.label(l10n),
              active: currentMode == TranslateInputMode.voice,
              raised:
                  voiceTab != null && currentMode == TranslateInputMode.voice,
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
    this.raised = false,
  });

  /// One of the [AppIcons].
  final String icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  /// The raised Voice tab is standing over this one: the icon shrinks away
  /// under its mic, and the label is its to show. The blank label keeps the
  /// tab's height.
  final bool raised;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;
    final radius = BorderRadius.circular(AppDimens.radiusChipL);

    return ExcludeSemantics(
      excluding: raised,
      child: Semantics(
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
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: active ? c.coral : c.textMuted),
                duration: AppMotion.dockColor,
                curve: Curves.ease,
                builder: (context, color, _) => Column(
                  children: [
                    AnimatedScale(
                      scale: raised ? AppMotion.shrunkScale : 1,
                      duration: AppMotion.modeSwitch,
                      curve: AppMotion.popCurve,
                      child: Opacity(
                        opacity: raised ? 0 : 1,
                        child: AppSvgIcon(icon, size: 22, color: color!),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      raised ? '' : label,
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
        ),
      ),
    );
  }
}
