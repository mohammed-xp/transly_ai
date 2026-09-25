import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/coming_soon_panel.dart';
import '../../../../l10n/app_localizations.dart';

class CameraScanScreen extends StatelessWidget {
  const CameraScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spaceL),
        child: ComingSoonPanel(
          icon: Icons.photo_camera_outlined,
          title: l10n.cameraScanComingSoonTitle,
          message: l10n.cameraScanComingSoonBody,
        ),
      ),
    );
  }
}
