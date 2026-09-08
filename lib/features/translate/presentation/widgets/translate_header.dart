import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';

/// Translate screen header: kicker + "Transly" title on the leading side, an
/// "AI Pro" plan badge and a sign-out action on the trailing side (design
/// `02 · Translate`).
class TranslateHeader extends StatelessWidget {
  const TranslateHeader({super.key, this.onSignOut});

  /// Called when the sign-out icon is tapped. `null` hides the icon.
  final VoidCallback? onSignOut;

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
          if (onSignOut != null) ...[
            _SignOutButton(onTap: onSignOut!, tooltip: l10n.authSignOut),
            const SizedBox(width: 10),
          ],
          _AiProBadge(label: l10n.translateAiPro),
        ],
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onTap, required this.tooltip});

  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.logout_rounded,
            size: AppDimens.iconM,
            color: c.textMuted,
          ),
        ),
      ),
    );
  }
}

class _AiProBadge extends StatelessWidget {
  const _AiProBadge({required this.label});

  final String label;

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
            decoration: BoxDecoration(color: c.coral, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(label, style: textTheme.titleSmall?.copyWith(color: c.ink)),
        ],
      ),
    );
  }
}
