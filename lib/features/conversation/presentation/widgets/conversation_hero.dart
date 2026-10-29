import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_svg_icon.dart';

/// Tinted icon tile, title and message, centered — the `Empty` and
/// `Mic denied` screens of design `Conversation v2`. [child] goes under the
/// message.
class ConversationHero extends StatelessWidget {
  const ConversationHero({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.child,
  });

  /// One of the [AppIcons].
  final String icon;
  final String title;
  final String message;
  final Widget? child;

  static const double _tileSize = 72;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;
    final child = this.child;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _tileSize,
          height: _tileSize,
          decoration: BoxDecoration(
            gradient: c.tintGradient,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: c.tintBorder),
          ),
          child: Center(child: AppSvgIcon(icon, size: 30, color: c.coralLabel)),
        ),
        const SizedBox(height: AppDimens.spaceXL),
        Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: c.ink,
          ),
        ),
        const SizedBox(height: AppDimens.spaceS),
        Text(
          message,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            height: 1.5,
            color: c.textSecondary,
          ),
        ),
        if (child != null) ...[
          const SizedBox(height: AppDimens.space2XL),
          child,
        ],
      ],
    );
  }
}
