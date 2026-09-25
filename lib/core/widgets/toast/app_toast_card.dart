import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_palette.dart';
import 'app_toast.dart';

/// The toast's visual (design `07 · Toast`): icon chip, message with optional
/// subtitle and highlight, optional action, and a 2px countdown bar.
/// Presentational only — timing and dismissal live in `AppToastScope`.
class AppToastCard extends StatelessWidget {
  const AppToastCard({
    super.key,
    required this.data,
    this.remaining,
    this.onAction,
  });

  final AppToastData data;

  /// Runs 1 → 0 over the toast's lifetime; null hides the countdown bar.
  final Animation<double>? remaining;

  /// Null hides the action button.
  final VoidCallback? onAction;

  static const double _padding = 14;
  static const double _paddingBesideAction = AppDimens.spaceS;
  static const double _countdownHeight = 2;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final remaining = this.remaining;
    final onAction = this.onAction;

    return Container(
      constraints: const BoxConstraints(minHeight: AppDimens.toastMinHeight),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.toastBackground,
        borderRadius: BorderRadius.circular(AppDimens.radiusButton),
        border: c.toastBorder == null
            ? null
            : Border.all(color: c.toastBorder!),
        boxShadow: [
          BoxShadow(
            color: c.toastShadow,
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              _padding,
              10,
              onAction == null ? _padding : _paddingBesideAction,
              10,
            ),
            child: Row(
              children: [
                _IconChip(type: data.type, icon: data.resolvedIcon),
                const SizedBox(width: AppDimens.spaceM),
                Expanded(
                  child: _ToastTexts(
                    message: data.message,
                    highlight: data.highlight,
                    subtitle: data.subtitle,
                  ),
                ),
                if (onAction != null) ...[
                  const SizedBox(width: AppDimens.spaceM),
                  _ToastActionButton(label: data.actionLabel!, onTap: onAction),
                ],
              ],
            ),
          ),
          if (remaining != null)
            PositionedDirectional(
              start: 0,
              end: 0,
              bottom: 0,
              height: _countdownHeight,
              child: _CountdownBar(remaining: remaining),
            ),
        ],
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.type, required this.icon});

  final AppToastType type;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final (Color? fill, Gradient? gradient, Color glyph) = switch (type) {
      AppToastType.success => (
        AppColors.accentDark.withValues(alpha: 0.16),
        null,
        AppColors.accentDark,
      ),
      AppToastType.neutral => (c.toastNeutralChip, null, c.toastNeutralIcon),
      AppToastType.error => (c.toastErrorChip, null, Colors.white),
      AppToastType.ai => (null, AppColors.brandGradient, Colors.white),
    };

    return Container(
      width: AppDimens.toastIconBox,
      height: AppDimens.toastIconBox,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppDimens.radiusChip),
      ),
      child: Icon(icon, size: type == AppToastType.ai ? 15 : 17, color: glyph),
    );
  }
}

class _ToastTexts extends StatelessWidget {
  const _ToastTexts({
    required this.message,
    required this.highlight,
    required this.subtitle,
  });

  final String message;
  final String? highlight;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final subtitle = this.subtitle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          _messageSpan(),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: c.toastText,
          ),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
                color: c.toastSubtext,
              ),
            ),
          ),
      ],
    );
  }

  TextSpan _messageSpan() {
    final highlight = this.highlight;
    final index = (highlight == null || highlight.isEmpty)
        ? -1
        : message.indexOf(highlight);
    if (highlight == null || index < 0) return TextSpan(text: message);

    return TextSpan(
      children: [
        TextSpan(text: message.substring(0, index)),
        TextSpan(
          text: highlight,
          style: const TextStyle(
            color: AppColors.accentDark2,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextSpan(text: message.substring(index + highlight.length)),
      ],
    );
  }
}

class _ToastActionButton extends StatelessWidget {
  const _ToastActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(AppDimens.radiusChip);

    return Semantics(
      button: true,
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.accentDark2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CountdownBar extends AnimatedWidget {
  const _CountdownBar({required Animation<double> remaining})
    : super(listenable: remaining);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: (listenable as Animation<double>).value,
      child: const DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.brandGradient),
      ),
    );
  }
}
