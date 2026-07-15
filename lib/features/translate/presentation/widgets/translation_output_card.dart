import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../l10n/app_localizations.dart';

/// Coral-tinted card holding the AI translation output: language label, "AI"
/// badge, speaker button, the translated text (RTL) and copy/save actions
/// (design `02 · Translate`). Actions are inert until state exists.
class TranslationOutputCard extends StatelessWidget {
  const TranslationOutputCard({
    super.key,
    required this.isDark,
    required this.language,
    required this.text,
  });

  final bool isDark;
  final String language;
  final String text;

  static const double _actionHeight = 38;
  static const double _actionRadius = 11;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final labelColor = isDark ? AppColors.accentDark2 : AppColors.rtlLabelLight;
    final coral = isDark ? AppColors.accentDark : AppColors.primary;
    final inkColor = isDark ? AppColors.textPrimaryDark : AppColors.inkLight;

    final gradient = isDark
        ? LinearGradient(
            begin: const Alignment(-0.3, -1),
            end: const Alignment(0.3, 1),
            colors: [
              AppColors.accentDark.withValues(alpha: 0.16),
              AppColors.deep.withValues(alpha: 0.08),
            ],
          )
        : const LinearGradient(
            begin: Alignment(-0.3, -1),
            end: Alignment(0.3, 1),
            colors: [AppColors.outputBgLight, AppColors.outputBgLight2],
          );
    final borderColor = isDark
        ? AppColors.accentDark.withValues(alpha: 0.32)
        : AppColors.tintBorderLight;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: borderColor),
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
                    style: textTheme.titleSmall?.copyWith(color: labelColor),
                  ),
                  const SizedBox(width: 7),
                  _AiBadge(coral: coral),
                ],
              ),
              Icon(Icons.volume_up_rounded, size: AppDimens.iconM, color: coral),
            ],
          ),
          const SizedBox(height: AppDimens.spaceS + 2),
          // TODO(translate): derive direction/alignment from the target
          // language once it is dynamic — RTL is correct only while the
          // placeholder target is Arabic.
          Text(
            text,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: textTheme.bodyLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              height: 1.55,
              color: inkColor,
            ),
          ),
          const SizedBox(height: AppDimens.spaceL - 2),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  isDark: isDark,
                  coral: coral,
                  icon: Icons.copy_rounded,
                  label: AppLocalizations.of(context)!.translateCopy,
                  onTap: () {/* TODO(translate): copy output */},
                ),
              ),
              const SizedBox(width: AppDimens.spaceS),
              Expanded(
                child: _ActionButton(
                  isDark: isDark,
                  coral: coral,
                  icon: Icons.check_circle_outline_rounded,
                  label: AppLocalizations.of(context)!.translateSave,
                  onTap: () {/* TODO(translate): save output */},
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
  const _AiBadge({required this.coral});

  final Color coral;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: coral,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
    required this.isDark,
    required this.coral,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool isDark;
  final Color coral;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(TranslationOutputCard._actionRadius);
    final bg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : AppColors.surfaceLight;
    final border =
        isDark ? Border.all(color: Colors.white.withValues(alpha: 0.08)) : null;
    final labelColor = isDark ? AppColors.textPrimaryDark : AppColors.inkLight;

    return DecoratedBox(
      decoration: BoxDecoration(color: bg, borderRadius: radius, border: border),
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
                Icon(icon, size: 15, color: coral),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: textTheme.titleSmall?.copyWith(color: labelColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
