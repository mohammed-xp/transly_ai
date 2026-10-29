import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../../../../l10n/app_localizations.dart';

/// "You're offline" card at the top of the Voice tab (design
/// `Conversation v2 · Offline`).
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;

    return Container(
      padding: const EdgeInsets.all(AppDimens.spaceM),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusButton),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c.tintFill,
              borderRadius: BorderRadius.circular(AppDimens.radiusChip),
            ),
            child: Center(
              child: AppSvgIcon(
                AppIcons.wifiOff,
                size: 18,
                color: c.coralLabel,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.conversationOfflineTitle,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: c.ink,
                  ),
                ),
                Text(
                  l10n.conversationOfflineBody,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
