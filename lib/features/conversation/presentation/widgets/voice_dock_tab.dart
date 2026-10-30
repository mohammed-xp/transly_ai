import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/conversation_cubit.dart';
import '../cubit/conversation_state.dart';
import 'pulse_ring.dart';

enum _MicLook { idle, recording, unavailable, denied }

/// The Voice tab of the input dock while it is the open tab: a mic raised
/// above the dock (design `Conversation v2`). Tap to record a turn, tap again
/// to send it. Grey and inert while a turn is translating, offline, out of
/// time, or without microphone access. A translating turn shows its progress
/// in the conversation, not here.
///
/// Stays mounted while another tab is open, so the mic can pop in and sink
/// back out (design `Mode Transition`).
class VoiceDockTab extends StatelessWidget {
  const VoiceDockTab({super.key, required this.open});

  /// Whether the Voice tab is the open tab. Closed, the mic is hidden and
  /// taps pass through to the dock's plain tab.
  final bool open;

  static const double micSize = 76;

  /// How far the mic rises above the dock's tab row.
  static const double raise = 44;

  static _MicLook _lookOf(ConversationState state) => switch (state.status) {
    ConversationMicDenied() => _MicLook.denied,
    ConversationTranslating() => _MicLook.unavailable,
    _ when !state.canUseMic => _MicLook.unavailable,
    ConversationRecording() => _MicLook.recording,
    ConversationIdle() => _MicLook.idle,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final label = AppLocalizations.of(context)!.translateDockVoice;

    return BlocSelector<ConversationCubit, ConversationState, _MicLook>(
      selector: _lookOf,
      builder: (context, look) {
        final enabled = look == _MicLook.idle || look == _MicLook.recording;
        return IgnorePointer(
          ignoring: !open,
          child: ExcludeSemantics(
            excluding: !open,
            child: Semantics(
              button: true,
              selected: true,
              enabled: enabled,
              label: label,
              excludeSemantics: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: enabled
                    ? context.read<ConversationCubit>().micTapped
                    : null,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MicMotion(
                      open: open,
                      child: _Mic(look: look),
                    ),
                    const SizedBox(height: 1),
                    if (open)
                      TweenAnimationBuilder<Color?>(
                        tween: ColorTween(
                          begin: c.textMuted,
                          end: enabled ? c.coral : c.textMuted,
                        ),
                        duration: AppMotion.dockColor,
                        curve: Curves.ease,
                        builder: (context, color, _) => Text(
                          label,
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: color,
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
    );
  }
}

/// Pops [child] in when the tab [open]s and sinks it out when it closes.
class _MicMotion extends StatelessWidget {
  const _MicMotion({required this.open, required this.child});

  final bool open;
  final Widget child;

  static const double _sink = 30;

  @override
  Widget build(BuildContext context) {
    final duration = open ? AppMotion.micIn : AppMotion.micOut;
    final curve = open ? AppMotion.popCurve : AppMotion.modeCurve;

    return AnimatedSlide(
      offset: open
          ? Offset.zero
          : const Offset(0, _sink / VoiceDockTab.micSize),
      duration: duration,
      curve: curve,
      child: AnimatedScale(
        scale: open ? 1 : AppMotion.shrunkScale,
        duration: duration,
        curve: curve,
        child: AnimatedOpacity(
          opacity: open ? 1 : 0,
          duration: open ? AppMotion.micFadeIn : AppMotion.micFadeOut,
          curve: Curves.ease,
          child: child,
        ),
      ),
    );
  }
}

class _Mic extends StatelessWidget {
  const _Mic({required this.look});

  final _MicLook look;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final enabled = look == _MicLook.idle || look == _MicLook.recording;
    final recording = look == _MicLook.recording;

    final Widget icon = switch (look) {
      _MicLook.idle => const AppSvgIcon(
        AppIcons.micFilled,
        size: 28,
        color: Colors.white,
      ),
      _MicLook.recording => const AppSvgIcon(
        AppIcons.stop,
        size: 24,
        color: Colors.white,
      ),
      _MicLook.unavailable => AppSvgIcon(
        AppIcons.micFilled,
        size: 28,
        color: c.textSecondary,
      ),
      _MicLook.denied => AppSvgIcon(
        AppIcons.micOff,
        size: 28,
        color: c.textSecondary,
      ),
    };

    return SizedBox.square(
      dimension: VoiceDockTab.micSize,
      child: Stack(
        children: [
          if (recording)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: PulseRing(color: c.coral),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: enabled ? null : c.border,
                gradient: enabled ? AppColors.brandGradient : null,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 5,
                ),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: AppColors.deep.withValues(
                            alpha: recording ? 0.4 : 0.32,
                          ),
                          blurRadius: 26,
                          offset: const Offset(0, 12),
                        ),
                      ]
                    : null,
              ),
              child: Center(child: icon),
            ),
          ),
        ],
      ),
    );
  }
}
