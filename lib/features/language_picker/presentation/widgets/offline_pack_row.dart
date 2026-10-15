import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/l10n/language_badge.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../../../../core/widgets/language_leading_tile.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/offline_model_status.dart';
import '../utils/language_picker_l10n.dart';

/// A language on the offline packs screen (design `12d · Offline Packs`),
/// with the control that downloads or removes it. A running download shows
/// no progress amount and can't be cancelled: the on-device engine reports
/// neither.
class OfflinePackRow extends StatelessWidget {
  const OfflinePackRow({
    super.key,
    required this.language,
    required this.status,
    required this.onDownload,
    required this.onRemove,
  });

  final LanguageEntity language;
  final OfflineModelStatus status;
  final VoidCallback onDownload;
  final VoidCallback onRemove;

  static const double _minHeight = 62;
  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    final trailing = _trailing(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _minHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.spaceL,
          vertical: AppDimens.spaceM,
        ),
        child: Row(
          children: [
            LanguageBadgeTile(
              badge: languageBadge(language.code),
              isSelected: false,
            ),
            const SizedBox(width: AppDimens.spaceM),
            Expanded(
              child: switch (status) {
                OfflineModelDownloading(:final isAuto) => _DownloadingDetails(
                  name: language.nativeName,
                  isAuto: isAuto,
                ),
                _ => _Details(
                  name: language.nativeName,
                  subtitle: _subtitle(context),
                ),
              },
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppDimens.spaceM),
              trailing,
            ],
          ],
        ),
      ),
    );
  }

  String? _subtitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final secondary = secondaryLanguageLabel(context, language);
    final tag = switch (status) {
      OfflineModelBuiltIn() => l10n.offlinePacksBuiltIn,
      OfflineModelDownloaded(isAuto: true) => l10n.offlinePacksAutoDownloaded,
      _ => null,
    };
    if (tag == null) return secondary;
    return secondary == null ? tag : '$secondary · $tag';
  }

  Widget? _trailing(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return switch (status) {
      OfflineModelNotDownloaded() => _ActionButton(
        icon: AppSvgIcon(AppIcons.download, size: _iconSize, color: c.coral),
        background: isDark ? AppColors.chipBgDark : AppColors.chipBgLight,
        tooltip: l10n.languagePickerDownloadOffline,
        onPressed: onDownload,
      ),
      OfflineModelDownloaded() => _ActionButton(
        icon: AppSvgIcon(AppIcons.trash, size: _iconSize, color: c.textMuted),
        tooltip: l10n.languagePickerRemoveOfflineConfirm,
        onPressed: onRemove,
      ),
      _ => null,
    };
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.name, required this.subtitle});

  final String name;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Name(name),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          _Caption(subtitle),
        ],
      ],
    );
  }
}

class _DownloadingDetails extends StatelessWidget {
  const _DownloadingDetails({required this.name, required this.isAuto});

  final String name;
  final bool isAuto;

  static const double _barHeight = 6;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(child: _Name(name)),
            if (isAuto) ...[
              const SizedBox(width: AppDimens.spaceS),
              const _AutoTag(),
            ],
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          child: LinearProgressIndicator(
            minHeight: _barHeight,
            backgroundColor: c.progressTrack,
            color: c.coral,
          ),
        ),
        const SizedBox(height: 6),
        _Caption(AppLocalizations.of(context)!.offlinePacksDownloading),
      ],
    );
  }
}

class _Name extends StatelessWidget {
  const _Name(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: context.palette.ink,
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontSize: 13,
        color: context.palette.textMuted,
      ),
    );
  }
}

/// Marks a download that auto-download started.
class _AutoTag extends StatelessWidget {
  const _AutoTag();

  static const double _height = 22;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: _height,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.spaceS),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.accentDark.withValues(alpha: 0.12)
            : AppColors.outputBgLight,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(
          color: isDark
              ? AppColors.accentDark.withValues(alpha: 0.30)
              : AppColors.tintBorderLight,
        ),
      ),
      child: Text(
        AppLocalizations.of(context)!.offlinePacksAutoTag,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: context.palette.coralLabel,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.background,
  });

  final Widget icon;
  final Color? background;
  final String tooltip;
  final VoidCallback onPressed;

  static const double _size = 36;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: icon,
      style: IconButton.styleFrom(
        backgroundColor: background,
        fixedSize: const Size.square(_size),
        minimumSize: const Size.square(_size),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusChip),
        ),
      ),
    );
  }
}
