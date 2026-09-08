import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_palette.dart';

/// Centered "not built yet" panel: icon, title, message — themed like the
/// translate feature's cards. Used by 2+ features (conversation, camera scan)
/// so it lives in `core/` (CLAUDE.md §A-2). Takes plain strings rather than
/// resolving `AppLocalizations` itself, matching e.g. `LanguageBar`.
class ComingSoonPanel extends StatelessWidget {
  const ComingSoonPanel({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;

    return Container(
      padding: const EdgeInsets.all(AppDimens.spaceXL),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: c.border),
        boxShadow: c.cardShadow == null
            ? null
            : [
                BoxShadow(
                  color: c.cardShadow!,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimens.iconL * 1.5, color: c.coral),
          const SizedBox(height: AppDimens.spaceM),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(color: c.ink),
          ),
          const SizedBox(height: AppDimens.spaceS),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: c.textMuted),
          ),
        ],
      ),
    );
  }
}
