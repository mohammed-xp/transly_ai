import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';

/// Translate screen header: kicker + "Transly" title on the leading side, an
/// "AI Pro" plan badge on the trailing side (design `02 · Translate`).
class TranslateHeader extends StatelessWidget {
  const TranslateHeader({super.key});

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
          _AiProBadge(label: l10n.translateAiPro),
        ],
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
          Text(
            label,
            style: textTheme.titleSmall?.copyWith(color: c.ink),
          ),
        ],
      ),
    );
  }
}
