import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/sheet_drag_handle.dart';
import '../../../../core/widgets/toast/app_toast.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/app_language.dart';
import '../cubit/app_language_cubit.dart';
import '../utils/app_language_l10n.dart';

/// Shows [AppLanguageSheet] (design `12c · App Language`) and applies the
/// language saved from it. Needs an [AppLanguageCubit] above [context].
Future<void> showAppLanguageSheet(BuildContext context) async {
  final cubit = context.read<AppLanguageCubit>();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final picked = await showModalBottomSheet<AppLanguage>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.palette.surface,
    barrierColor: isDark
        ? Colors.black.withValues(alpha: 0.6)
        : AppColors.backgroundDark.withValues(alpha: 0.45),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppLanguageSheet.topRadius),
      ),
    ),
    builder: (_) => AppLanguageSheet(initial: cubit.state),
  );
  if (picked == null) return;

  final saved = await cubit.changeLanguage(picked);
  if (saved || !context.mounted) return;
  AppToast.show(
    context,
    message: AppLocalizations.of(context)!.appLanguageSaveFailed,
    type: AppToastType.error,
  );
}

/// Picking an option only moves the selection; Save closes the sheet with it
/// as the result, and the close button closes it with none.
class AppLanguageSheet extends StatefulWidget {
  const AppLanguageSheet({super.key, required this.initial});

  static const double topRadius = 28;

  final AppLanguage initial;

  @override
  State<AppLanguageSheet> createState() => _AppLanguageSheetState();
}

class _AppLanguageSheetState extends State<AppLanguageSheet> {
  late AppLanguage _selected = widget.initial;

  void _select(AppLanguage language) => setState(() => _selected = language);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;
    final deviceLanguage = l10n.languageName(
      deviceResolvedLanguageCode(context),
    );

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, AppDimens.spaceXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: SheetDragHandle()),
            const SizedBox(height: 18),
            const _Header(),
            const SizedBox(height: AppDimens.spaceL),
            _LanguageOption(
              leading: _DeviceIcon(isSelected: _selected.isDevice),
              title: l10n.appLanguageDevice,
              subtitle: l10n.appLanguageDeviceAuto(deviceLanguage),
              isSelected: _selected.isDevice,
              isOutlined: true,
              minHeight: 56,
              onTap: () => _select(AppLanguage.device),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 16, 6, 6),
              child: Text(
                l10n.appLanguageAllLanguages,
                style: textTheme.labelMedium?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.36,
                  color: c.textMuted,
                ),
              ),
            ),
            for (final code in appLanguageCodes())
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.spaceXS),
                child: _LanguageOption(
                  leading: _LanguageBadge(
                    code: code,
                    isSelected: _selected.code == code,
                  ),
                  title: nativeLanguageName(code),
                  subtitle: secondaryLanguageName(context, code),
                  isSelected: _selected.code == code,
                  onTap: () => _select(AppLanguage(code)),
                ),
              ),
            const SizedBox(height: 14),
            GradientButton(
              label: l10n.appLanguageSave,
              onPressed: () => Navigator.of(context).pop(_selected),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.spaceXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appLanguageSheetTitle,
                  style: textTheme.headlineMedium?.copyWith(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: c.ink,
                  ),
                ),
                const SizedBox(height: AppDimens.spaceXS),
                Text(
                  l10n.appLanguageSheetSubtitle,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    height: 1.5,
                    color: c.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.spaceM),
          const _CloseButton(),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton();

  static const double _size = 34;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).closeButtonTooltip,
      child: Material(
        color: isDark ? AppColors.chipBgDark : AppColors.chipBgLight,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.of(context).pop(),
          child: SizedBox.square(
            dimension: _size,
            child: Icon(
              Icons.close_rounded,
              size: AppDimens.iconS,
              color: context.palette.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.isOutlined = false,
    this.minHeight = 60,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isOutlined;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;
    final radius = BorderRadius.circular(AppDimens.radiusButton);
    final subtitle = this.subtitle;

    final Color background;
    final Color borderColor;
    if (isSelected) {
      background = isDark
          ? AppColors.accentDark.withValues(alpha: 0.12)
          : AppColors.outputBgLight;
      borderColor = isDark
          ? AppColors.accentDark.withValues(alpha: 0.30)
          : AppColors.tintBorderLight;
    } else {
      background = Colors.transparent;
      borderColor = isOutlined ? c.border : Colors.transparent;
    }

    return Semantics(
      selected: isSelected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: borderColor),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: AppDimens.spaceS,
              ),
              child: Row(
                children: [
                  leading,
                  const SizedBox(width: AppDimens.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: c.ink,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            subtitle,
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              color: c.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.spaceM),
                  _RadioMark(isSelected: isSelected),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LeadingTile extends StatelessWidget {
  const _LeadingTile({required this.isSelected, required this.child});

  final bool isSelected;
  final Widget child;

  static const double _size = 38;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: isSelected ? AppColors.brandGradient : null,
        color: isSelected
            ? null
            : (isDark ? AppColors.chipBgDark : AppColors.chipBgLight),
        borderRadius: BorderRadius.circular(AppDimens.radiusChipL),
      ),
      child: child,
    );
  }
}

class _DeviceIcon extends StatelessWidget {
  const _DeviceIcon({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return _LeadingTile(
      isSelected: isSelected,
      child: Icon(
        Icons.smartphone_rounded,
        size: 18,
        color: isSelected ? Colors.white : context.palette.textSecondary,
      ),
    );
  }
}

class _LanguageBadge extends StatelessWidget {
  const _LanguageBadge({required this.code, required this.isSelected});

  final String code;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final badge = appLanguageBadge(code);

    return _LeadingTile(
      isSelected: isSelected,
      child: Text(
        badge,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          // A single letter is drawn larger than a two-letter code.
          fontSize: badge.characters.length == 1 ? 17 : 13,
          fontWeight: FontWeight.w700,
          color: isSelected ? Colors.white : context.palette.textSecondary,
        ),
      ),
    );
  }
}

class _RadioMark extends StatelessWidget {
  const _RadioMark({required this.isSelected});

  final bool isSelected;

  static const double _size = 24;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = context.palette;

    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? c.coral : null,
        border: isSelected
            ? null
            : Border.all(
                color: isDark
                    ? AppColors.radioRingDark
                    : AppColors.radioRingLight,
                width: 2,
              ),
      ),
      child: isSelected
          ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
          : null,
    );
  }
}
