import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
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
class VoiceDockTab extends StatelessWidget {
  const VoiceDockTab({super.key});

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
        return Semantics(
          button: true,
          selected: true,
          enabled: enabled,
          label: label,
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? context.read<ConversationCubit>().micTapped : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Mic(look: look),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: enabled ? c.coral : c.textMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
