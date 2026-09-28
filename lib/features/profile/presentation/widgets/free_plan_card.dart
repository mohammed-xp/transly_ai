import 'package:flutter/material.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/l10n/failure_message.dart';
import '../../../../core/l10n/localized_digits.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/sparkle_icon.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/plan_usage_entity.dart';
import '../utils/plan_usage_l10n.dart';

class FreePlanCard extends StatelessWidget {
  const FreePlanCard({super.key, required this.usage, required this.onUpgrade});

  final PlanUsageEntity usage;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;
    final captionStyle = textTheme.bodySmall?.copyWith(
      fontSize: 13,
      color: c.textSecondary,
    );

    return _PlanCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const SizedBox(width: AppDimens.spaceM),
              Text(
                l10n.profileUsagePercent(
                  localizedDigits(context, usage.usedPercent),
                ),
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.24,
                  color: c.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceM),
          _UsageMeter(fraction: usage.usedFraction),
          const SizedBox(height: AppDimens.spaceM),
          Row(
            children: [
              Expanded(
                child: Text(l10n.profileUsageToday, style: captionStyle),
              ),
              Text(
                l10n.profileUsageRemaining(
                  localizedDigits(context, usage.remainingPercent),
                ),
                style: captionStyle,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceM),
          _UpgradeButton(onTap: onUpgrade),
        ],
      ),
    );
  }
}

/// Holds the card's footprint while usage loads so the sections below don't
/// jump when it arrives.
class FreePlanCardSkeleton extends StatelessWidget {
  const FreePlanCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlanCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          SizedBox(height: AppDimens.spaceM),
          _UsageMeter(fraction: 0),
          SizedBox(height: AppDimens.spaceM),
          _SkeletonBar(height: 14),
          SizedBox(height: AppDimens.spaceM),
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
      child: SparkleIcon(size: 17, color: context.palette.textSecondary),
    );
  }
}

class _UsageMeter extends StatelessWidget {
  const _UsageMeter({required this.fraction});

  final double fraction;

  static const double _height = 8;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimens.radiusPill);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: _height,
        child: ColoredBox(
          color: Theme.of(context).colorScheme.outlineVariant,
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
                const SparkleIcon(size: 17, color: Colors.white),
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
