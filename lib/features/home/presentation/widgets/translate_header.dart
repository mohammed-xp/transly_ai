import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../l10n/app_localizations.dart';

class TranslateHeader extends StatelessWidget {
  const TranslateHeader({
    super.key,
    required this.userName,
    required this.isPro,
    required this.onProfileTap,
  });

  final String? userName;
  final bool isPro;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.spaceXL,
        6,
        AppDimens.spaceXL,
        AppDimens.spaceM,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translateKicker,
                  style: textTheme.labelMedium?.copyWith(color: c.textMuted),
                ),
                Text(
                  'Transly', // brand name — not localized
                  style: textTheme.headlineLarge?.copyWith(color: c.ink),
                ),
              ],
            ),
          ),
          _PlanBadge(
            label: isPro ? l10n.translateAiPro : l10n.translateAiFree,
            isPro: isPro,
          ),
          const SizedBox(width: 10),
          _ProfileAvatarButton(
            userName: userName,
            label: l10n.profileOpen,
            onTap: onProfileTap,
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatarButton extends StatelessWidget {
  const _ProfileAvatarButton({
    required this.userName,
    required this.label,
    required this.onTap,
  });

  final String? userName;
  final String label;
  final VoidCallback onTap;

  static const double _size = 44;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: UserAvatar(
          name: userName,
          size: _size,
          ringWidth: 2,
          glow: !isDark,
        ),
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.label, required this.isPro});

  final String label;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(color: c.border),
        boxShadow: c.cardShadow == null
            ? null
            : [
                BoxShadow(
                  color: c.cardShadow!,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: isPro ? c.coral : c.textMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(label, style: textTheme.titleSmall?.copyWith(color: c.ink)),
        ],
      ),
    );
  }
}
