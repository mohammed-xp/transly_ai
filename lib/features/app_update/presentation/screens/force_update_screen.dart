import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/decorative_blob.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/transly_logo.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/app_update_entity.dart';
import '../utils/open_app_store.dart';

/// Blocks the app until it is updated (design `13b · Update`).
class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key, required this.update});

  final AppUpdateEntity update;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;
    final storeLabel = defaultTargetPlatform == TargetPlatform.iOS
        ? l10n.updateFromAppStore
        : l10n.updateFromPlayStore;

    return Scaffold(
      backgroundColor: c.screenBackground,
      body: Stack(
        children: [
          const DecorativeBlob(
            AppColors.primary,
            opacity: 0.10,
            diameter: 300,
            top: -120,
            right: -90,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.space2XL,
                0,
                AppDimens.space2XL,
                AppDimens.spaceL,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        clipBehavior: Clip.none,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const TranslyLogo(),
                            const SizedBox(height: AppDimens.space3XL),
                            Text(
                              l10n.updateRequiredTitle,
                              textAlign: TextAlign.center,
                              style: textTheme.headlineLarge?.copyWith(
                                color: c.ink,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 310),
                              child: Text(
                                l10n.updateRequiredBody,
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontSize: 15,
                                  height: 1.6,
                                  color: c.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            _VersionPill(update: update),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GradientButton(
                    label: storeLabel,
                    icon: Icons.download_rounded,
                    onPressed: () => openAppStore(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Your version → Latest", always laid out left-to-right like the version
/// numbers themselves.
class _VersionPill extends StatelessWidget {
  const _VersionPill({required this.update});

  final AppUpdateEntity update;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;
    final versionStyle = textTheme.titleMedium?.copyWith(fontSize: 15);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: c.inputFill,
          borderRadius: BorderRadius.circular(AppDimens.radiusButton),
          border: Border.all(color: c.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _VersionColumn(
              label: l10n.updateYourVersion,
              version: update.installedVersion,
              versionStyle: versionStyle?.copyWith(
                color: c.textMuted,
                decoration: TextDecoration.lineThrough,
                decorationColor: c.textMuted,
              ),
            ),
            const SizedBox(width: 14),
            Icon(Icons.arrow_forward_rounded, size: 22, color: c.coral),
            const SizedBox(width: 14),
            _VersionColumn(
              label: l10n.updateLatestVersion,
              version: update.latestVersion,
              versionStyle: versionStyle?.copyWith(
                fontWeight: FontWeight.w700,
                color: c.coral,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionColumn extends StatelessWidget {
  const _VersionColumn({
    required this.label,
    required this.version,
    required this.versionStyle,
  });

  final String label;
  final String version;
  final TextStyle? versionStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w400,
            color: context.palette.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(version, style: versionStyle),
      ],
    );
  }
}
