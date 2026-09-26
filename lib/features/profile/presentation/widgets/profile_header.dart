import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../l10n/app_localizations.dart';

/// Back chip · centered title · "Edit" action (design `12 · Profile`).
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.onBack, required this.onEdit});

  final VoidCallback onBack;
  final VoidCallback onEdit;

  static const double _height = 40;

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
        14,
      ),
      child: SizedBox(
        height: _height,
        child: NavigationToolbar(
          leading: AppBackButton(onTap: onBack, fillColor: c.surface),
          middle: Text(
            l10n.profileTitle,
            style: textTheme.titleLarge?.copyWith(color: c.ink),
          ),
          trailing: _EditAction(label: l10n.profileEdit, onTap: onEdit),
        ),
      ),
    );
  }
}

class _EditAction extends StatelessWidget {
  const _EditAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;

    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusChip),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spaceXS,
            vertical: AppDimens.spaceS,
          ),
          child: Text(
            label,
            style: textTheme.titleMedium?.copyWith(
              fontSize: 15,
              color: c.coral,
            ),
          ),
        ),
      ),
    );
  }
}
