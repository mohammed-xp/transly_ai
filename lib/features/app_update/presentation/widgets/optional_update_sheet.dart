import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/transly_logo.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/app_update_entity.dart';

/// Shows [OptionalUpdateSheet] (design `13 · Update`). The sheet closes
/// before [onUpdate] runs.
Future<void> showOptionalUpdateSheet(
  BuildContext context, {
  required AppUpdateEntity update,
  required VoidCallback onUpdate,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.palette.surface,
    barrierColor: isDark
        ? Colors.black.withValues(alpha: 0.6)
        : AppColors.backgroundDark.withValues(alpha: 0.45),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(OptionalUpdateSheet.topRadius),
      ),
    ),
    builder: (sheetContext) => OptionalUpdateSheet(
      update: update,
      onUpdate: () {
        Navigator.of(sheetContext).pop();
        onUpdate();
      },
      onLater: () => Navigator.of(sheetContext).pop(),
    ),
  );
}

class OptionalUpdateSheet extends StatelessWidget {
  const OptionalUpdateSheet({
    super.key,
    required this.update,
    required this.onUpdate,
    required this.onLater,
  });

  static const double topRadius = 28;

  final AppUpdateEntity update;
  final VoidCallback onUpdate;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        clipBehavior: Clip.none,
        padding: const EdgeInsets.fromLTRB(22, 10, 22, AppDimens.spaceXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _DragHandle(),
            const SizedBox(height: AppDimens.space2XL),
            _BadgedLogo(badge: l10n.updateNewBadge),
            const SizedBox(height: AppDimens.spaceXL),
            Text(
              l10n.updateOptionalTitle,
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium?.copyWith(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: c.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.updateVersionLabel(update.latestVersion),
              textDirection: TextDirection.ltr,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 13,
                color: c.textMuted,
              ),
            ),
            if (update.releaseNotes.isNotEmpty) ...[
              const SizedBox(height: 18),
              _ReleaseNotes(notes: update.releaseNotes),
            ],
            const SizedBox(height: 18),
            GradientButton(label: l10n.updateNow, onPressed: onUpdate),
            const SizedBox(height: 10),
            _LaterButton(label: l10n.updateLater, onPressed: onLater),
          ],
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: isDark ? AppColors.sheetHandleDark : AppColors.sheetHandleLight,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
    );
  }
}

class _BadgedLogo extends StatelessWidget {
  const _BadgedLogo({required this.badge});

  final String badge;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        const TranslyLogo.compact(),
        PositionedDirectional(
          top: -8,
          end: -12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: c.ink,
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
              border: Border.all(color: c.surface, width: 2),
            ),
            child: Text(
              badge,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: c.surface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReleaseNotes extends StatelessWidget {
  const _ReleaseNotes({required this.notes});

  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final c = context.palette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spaceL,
        vertical: AppDimens.spaceS,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusButton),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 2),
            child: Text(
              l10n.updateWhatsNew,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: c.textMuted,
              ),
            ),
          ),
          for (final note in notes) _ReleaseNoteRow(note: note),
        ],
      ),
    );
  }
}

class _ReleaseNoteRow extends StatelessWidget {
  const _ReleaseNoteRow({required this.note});

  static const double _minHeight = 44;
  static const double _chipSize = 26;

  final String note;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = context.palette;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _minHeight),
      child: Row(
        children: [
          Container(
            width: _chipSize,
            height: _chipSize,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.accentDark.withValues(alpha: 0.12)
                  : AppColors.outputBgLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.check_rounded,
              size: AppDimens.iconS,
              color: c.coral,
            ),
          ),
          const SizedBox(width: AppDimens.spaceM),
          Expanded(
            child: Text(
              note,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: c.ink, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _LaterButton extends StatelessWidget {
  const _LaterButton({required this.label, required this.onPressed});

  static const double _height = 52;

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return Material(
      color: c.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusButton),
        side: BorderSide(color: c.border),
      ),
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: double.infinity,
          height: _height,
          child: Center(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: c.ink),
            ),
          ),
        ),
      ),
    );
  }
}
