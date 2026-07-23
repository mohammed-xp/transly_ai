import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../l10n/app_localizations.dart';

/// Tappable speaker icon shared by the source and translation output cards.
/// Null [onTap] renders it dimmed and inert (nothing to speak) — same disabled
/// pattern as the output card's Copy/Save action buttons.
///
/// The icon carries no visible text, so it supplies its own semantics label;
/// the box is sized up from the bare icon to keep the tap target reachable.
class SpeakerButton extends StatelessWidget {
  const SpeakerButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  /// Tap-target box. Larger than the 20px icon for reachability while staying
  /// close enough to the icon's footprint not to reshape the card headers.
  static const double _tapTargetSize = 40;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: AppLocalizations.of(context)!.translateListen,
      child: Opacity(
        opacity: onTap != null ? 1 : 0.45,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: _tapTargetSize,
              height: _tapTargetSize,
              child: Icon(icon, size: AppDimens.iconM, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
