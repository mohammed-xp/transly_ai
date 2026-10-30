import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show OverflowBoxFit;

import '../../../../core/constants/app_icons.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/l10n/failure_message.dart';
import '../../../../core/l10n/localized_digits.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/plan_usage_entity.dart';
import '../utils/plan_usage_l10n.dart';

const double _cardGap = 14;

/// The free plan's two quotas, translation and conversation, as one bar each
/// (design `Profile Usage` · 1a).
class FreePlanCard extends StatelessWidget {
  const FreePlanCard({super.key, required this.usage, this.onUpgrade});

  final PlanUsageEntity usage;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;
    const mark = _UsageRow.highlightMark;

    return _PlanCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: _cardGap,
        children: [
          Row(
            children: [
              const _PlanIconChip(),
              const SizedBox(width: AppDimens.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profileFreePlanTitle,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        color: c.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      resetCountdownLabel(context, usage),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: c.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          _UsageRow(
            icon: AppIcons.translate,
            label: l10n.profileUsageTranslation,
            value: l10n.profileUsageUsed(mark),
            highlight: l10n.profileUsagePercent(
              localizedDigits(context, usage.usedPercent),
            ),
            fraction: usage.usedFraction,
            exhausted: usage.charactersExhausted,
            pausedNote: usage.conversationAvailable
                ? l10n.profileUsagePausedConversationLeft
                : l10n.profileUsagePaused,
          ),
          if (usage case PlanUsageEntity(
            audioMinutesUsed: final int minutesUsed,
            audioMinutesLimit: final int minutesLimit,
            audioUsedFraction: final double fraction,
          ))
            _UsageRow(
              icon: AppIcons.conversation,
              label: l10n.profileUsageConversation,
              value: l10n.profileUsageMinutes(
                minutesLimit,
                mark,
                localizedDigits(context, minutesLimit),
              ),
              highlight: localizedDigits(context, minutesUsed),
              fraction: fraction,
              exhausted: usage.audioExhausted,
              pausedNote: usage.charactersExhausted
                  ? l10n.profileUsagePaused
                  : l10n.profileUsagePausedTranslationLeft,
            ),
          if (onUpgrade != null) _UpgradeButton(onTap: onUpgrade!),
        ],
      ),
    );
  }
}

class FreePlanCardSkeleton extends StatelessWidget {
  const FreePlanCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlanCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: _cardGap,
        children: [
          Row(
            children: [
              _PlanIconChip(),
              SizedBox(width: AppDimens.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBar(width: 110, height: 14),
                    SizedBox(height: 8),
                    _SkeletonBar(width: 170, height: 12),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 1),
          _UsageRowSkeleton(),
          _UsageRowSkeleton(),
          _SkeletonBar(height: 48, radius: AppDimens.radiusInput),
        ],
      ),
    );
  }
}

class PlanUsageErrorCard extends StatelessWidget {
  const PlanUsageErrorCard({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;

    return _PlanCardShell(
      child: Row(
        children: [
          const _PlanIconChip(),
          const SizedBox(width: AppDimens.spaceM),
          Expanded(
            child: Text(
              failureMessage(context, failure),
              style: textTheme.bodySmall?.copyWith(
                fontSize: 13,
                color: c.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.spaceS),
          InkWell(
            onTap: onRetry,
            borderRadius: BorderRadius.circular(AppDimens.radiusChip),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.spaceS,
                vertical: 6,
              ),
              child: Text(
                AppLocalizations.of(context)!.commonRetry,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                  color: c.coral,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCardShell extends StatelessWidget {
  const _PlanCardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        side: BorderSide(color: c.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spaceL),
        child: child,
      ),
    );
  }
}

class _PlanIconChip extends StatelessWidget {
  const _PlanIconChip();

  static const double _size = 38;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimens.radiusChipL),
      ),
      child: AppSvgIcon(
        AppIcons.sparkle,
        size: 17,
        color: context.palette.textSecondary,
      ),
    );
  }
}

/// One quota: its label, how much is used and a bar. Once [exhausted], the
/// row turns tinted, gains the used-up badge and shows [pausedNote] under the
/// bar.
class _UsageRow extends StatelessWidget {
  const _UsageRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.highlight,
    required this.fraction,
    required this.exhausted,
    required this.pausedNote,
  });

  /// Stands in [value] for the bold [highlight], so the right number is
  /// bolded whatever the word order of the language.
  static const String highlightMark = '\u{FFFC}';

  final String icon;
  final String label;
  final String value;
  final String highlight;
  final double fraction;
  final bool exhausted;
  final String pausedNote;

  static const double _gap = 10;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppDimens.spaceS,
      children: [
        Row(
          spacing: _gap,
          children: [
            _UsageIconChip(
              icon: icon,
              background: exhausted ? c.surface : c.tintFill,
            ),
            // The badge flows after the label, so a tight row drops it
            // before it cuts the label.
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: label,
                  children: [
                    if (exhausted)
                      const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(start: _gap),
                          child: _UsedUpBadge(),
                        ),
                      ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 15,
                  color: c.ink,
                ),
              ),
            ),
            Text.rich(
              _valueSpan(),
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: c.textSecondary,
              ),
            ),
          ],
        ),
        _UsageMeter(
          fraction: fraction,
          trackColor: exhausted ? c.tintBorder : null,
        ),
        if (exhausted)
          Text(
            pausedNote,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 13,
              color: c.coralLabel,
            ),
          ),
      ],
    );
    if (!exhausted) return content;

    return _Bleed(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.tintFill,
          border: Border.all(color: c.tintBorder),
          borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spaceM),
          child: content,
        ),
      ),
    );
  }

  TextSpan _valueSpan() {
    final parts = value.split(highlightMark);
    if (parts.length != 2) {
      return TextSpan(text: value.replaceAll(highlightMark, highlight));
    }

    return TextSpan(
      children: [
        TextSpan(text: parts.first),
        TextSpan(
          text: highlight,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        TextSpan(text: parts.last),
      ],
    );
  }
}

class _UsageRowSkeleton extends StatelessWidget {
  const _UsageRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppDimens.spaceS,
      children: [
        Row(
          spacing: _UsageRow._gap,
          children: [
            _SkeletonBar(
              width: _UsageIconChip._size,
              height: _UsageIconChip._size,
              radius: AppDimens.radiusChip,
            ),
            _SkeletonBar(width: 90, height: 14),
          ],
        ),
        _UsageMeter(fraction: 0),
      ],
    );
  }
}

class _UsageIconChip extends StatelessWidget {
  const _UsageIconChip({required this.icon, required this.background});

  final String icon;
  final Color background;

  static const double _size = 30;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppDimens.radiusChip),
      ),
      child: AppSvgIcon(
        icon,
        size: AppDimens.iconS,
        color: context.palette.coral,
      ),
    );
  }
}

class _UsedUpBadge extends StatelessWidget {
  const _UsedUpBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.coral,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        child: Text(
          AppLocalizations.of(context)!.profileUsageUsedUp,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Widens [child] past the card's padding by [_bleed] on each side, as the
/// design draws a spent quota.
class _Bleed extends StatelessWidget {
  const _Bleed({required this.child});

  final Widget child;

  static const double _bleed = 4;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth + _bleed * 2;
        return OverflowBox(
          minWidth: width,
          maxWidth: width,
          fit: OverflowBoxFit.deferToChild,
          child: child,
        );
      },
    );
  }
}

class _UsageMeter extends StatelessWidget {
  const _UsageMeter({required this.fraction, this.trackColor});

  final double fraction;

  /// Defaults to the theme's divider colour.
  final Color? trackColor;

  static const double _height = 6;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimens.radiusPill);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: _height,
        child: ColoredBox(
          color: trackColor ?? Theme.of(context).colorScheme.outlineVariant,
          child: FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: fraction,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: radius,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UpgradeButton extends StatelessWidget {
  const _UpgradeButton({required this.onTap});

  final VoidCallback onTap;

  static const double _height = 48;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimens.radiusInput);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: radius,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: SizedBox(
            height: _height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppSvgIcon(
                  AppIcons.sparkle,
                  size: 17,
                  color: Colors.white,
                ),
                const SizedBox(width: AppDimens.spaceS),
                Text(
                  AppLocalizations.of(context)!.profileUpgradeToPro,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({this.width, required this.height, this.radius = 6});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
