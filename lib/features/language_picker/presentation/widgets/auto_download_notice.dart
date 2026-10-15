import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/l10n/language_label.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../../../../core/widgets/spinning_ring.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/auto_download_notice_cubit.dart';
import '../cubit/auto_download_notice_state.dart';

/// A language downloading in the background after an online translation
/// (design `02d · Auto-download`). Needs an [AutoDownloadNoticeCubit] above
/// it. The ring spins rather than filling up: the on-device engine reports
/// no progress.
class AutoDownloadNotice extends StatelessWidget {
  const AutoDownloadNotice({super.key});

  static const Duration _resizeDuration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AutoDownloadNoticeCubit, AutoDownloadNoticeState>(
      builder: (context, state) => AnimatedSize(
        duration: _resizeDuration,
        alignment: AlignmentDirectional.topCenter,
        child: switch (state) {
          AutoDownloadNoticeHidden() => const SizedBox(width: double.infinity),
          AutoDownloadNoticeShown() => Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.spaceM),
            child: _NoticeCard(state: state),
          ),
        },
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.state});

  final AutoDownloadNoticeShown state;

  static const double _radius = 16;
  static const double _ringSize = 34;
  static const double _closeSize = 28;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;
    final cardShadow = c.cardShadow;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spaceM,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: c.border),
        boxShadow: [
          if (cardShadow != null)
            BoxShadow(
              color: cardShadow,
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          SizedBox.square(
            dimension: _ringSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SpinningRing(
                  size: _ringSize,
                  stroke: 3,
                  trackColor: c.progressTrack,
                  activeColor: c.coral,
                  duration: const Duration(milliseconds: 1200),
                ),
                AppSvgIcon(AppIcons.downloadNotice, size: 14, color: c.coral),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.autoDownloadNoticeTitle(
                    languageLabel(context, state.language),
                  ),
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: c.ink,
                  ),
                ),
                if (state.wifiOnly) ...[
                  const SizedBox(height: 2),
                  Text(
                    l10n.autoDownloadNoticeWifi,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppDimens.spaceS),
          IconButton(
            onPressed: context.read<AutoDownloadNoticeCubit>().dismiss,
            tooltip: l10n.autoDownloadNoticeHide,
            icon: AppSvgIcon(AppIcons.close, size: 12, color: c.textMuted),
            style: IconButton.styleFrom(
              fixedSize: const Size.square(_closeSize),
              minimumSize: const Size.square(_closeSize),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
