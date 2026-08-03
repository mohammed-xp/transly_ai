import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/spinning_ring.dart';
import '../../../../l10n/app_localizations.dart';
import 'speaker_button.dart';
import 'translating_dots.dart';
import 'translation_skeleton.dart';

/// Coral-tinted card holding the AI translation output: language label, "AI"
/// badge, speaker button, the translated text, a status slot (translating /
/// error), and copy/save actions (design `02 · Translate` / `02b · Translating`).
class TranslationOutputCard extends StatelessWidget {
  const TranslationOutputCard({
    super.key,
    required this.language,
    required this.text,
    required this.textDirection,
    required this.busyLabel,
    required this.errorMessage,
    required this.onCopy,
    required this.onSpeak,
  });

  final String language;
  final String text;

  /// Derived by the caller from the target language's direction.
  final TextDirection textDirection;

  /// Non-null while downloading a model or translating — replaces the speaker
  /// button with a bouncing-dots label and the body with a shimmer skeleton.
  final String? busyLabel;

  /// Non-null on translation failure — shown in place of the output text.
  final String? errorMessage;

  /// Invoked when Copy is tapped; null disables the button (nothing to copy).
  final VoidCallback? onCopy;

  /// Invoked when the speaker icon is tapped; null disables it (nothing to speak).
  final VoidCallback? onSpeak;

  bool get _isBusy => busyLabel != null;

  static const double _actionHeight = 38;
  static const double _actionRadius = 11;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: c.outputGradient,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: c.outputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    language,
                    style: textTheme.titleSmall?.copyWith(color: c.coralLabel),
                  ),
                  const SizedBox(width: 7),
                  _AiBadge(isBusy: _isBusy),
                ],
              ),
              if (_isBusy)
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          busyLabel!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall
                              ?.copyWith(fontSize: 12, color: c.coralLabel),
                        ),
                      ),
                      const SizedBox(width: 6),
                      TranslatingDots(color: c.coral),
                    ],
                  ),
                )
              else
                SpeakerButton(
                  icon: Icons.volume_up_rounded,
                  color: c.coral,
                  onTap: onSpeak,
                ),
            ],
          ),
          SizedBox(height: _isBusy ? 14 : AppDimens.spaceS + 2),
          if (_isBusy)
            TranslationSkeleton(textDirection: textDirection)
          else if (text.isNotEmpty)
            Text(
              text,
              textAlign: textDirection == TextDirection.rtl
                  ? TextAlign.right
                  : TextAlign.left,
              textDirection: textDirection,
              style: textTheme.bodyLarge?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                height: 1.55,
                color: c.ink,
              ),
            ),
          if (errorMessage != null) ...[
            if (text.isNotEmpty) const SizedBox(height: AppDimens.spaceS),
            Text(
              errorMessage!,
              style: textTheme.titleSmall?.copyWith(color: c.textMuted),
            ),
          ],
          const SizedBox(height: AppDimens.spaceL - 2),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.copy_rounded,
                  label: AppLocalizations.of(context)!.translateCopy,
                  onTap: onCopy,
                ),
              ),
              const SizedBox(width: AppDimens.spaceS),
              Expanded(
                child: _ActionButton(
                  icon: Icons.check_circle_outline_rounded,
                  label: AppLocalizations.of(context)!.translateSave,
                  onTap: null, // save/history is future scope
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiBadge extends StatelessWidget {
  const _AiBadge({required this.isBusy});

  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: c.coral,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isBusy)
            SpinningRing(
              size: 9,
              stroke: 1.6,
              trackColor: Colors.white.withValues(alpha: 0.45),
              activeColor: Colors.white,
              duration: const Duration(milliseconds: 700),
            )
          else
            const Icon(Icons.auto_awesome, size: 10, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            l10n.translateAiBadge,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;

  /// Null renders the button disabled (dimmed, no ink response).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;
    final radius = BorderRadius.circular(TranslationOutputCard._actionRadius);
    final border = c.actionBorder == null
        ? null
        : Border.all(color: c.actionBorder!);
    final enabled = onTap != null;

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.actionSurface,
          borderRadius: radius,
          border: border,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: SizedBox(
              height: TranslationOutputCard._actionHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 15, color: c.coral),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: textTheme.titleSmall?.copyWith(color: c.ink),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
