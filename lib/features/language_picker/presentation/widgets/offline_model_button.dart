import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/spinning_ring.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/offline_model_status.dart';

/// Downloads a language for offline use, shows the download running, and
/// marks the language once it is on the device. Nothing for a language the
/// on-device engine doesn't support, or whose status isn't known yet.
class OfflineModelButton extends StatelessWidget {
  const OfflineModelButton({
    super.key,
    required this.status,
    required this.onDownload,
    required this.onRemove,
  });

  final OfflineModelStatus? status;
  final VoidCallback onDownload;
  final VoidCallback onRemove;

  static const double _size = 40;
  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.palette;

    return switch (status) {
      null || OfflineModelUnsupported() => const SizedBox.shrink(),
      OfflineModelNotDownloaded() => _button(
        icon: Icons.download_rounded,
        color: c.textMuted,
        tooltip: l10n.languagePickerDownloadOffline,
        onPressed: onDownload,
      ),
      OfflineModelDownloading() => Semantics(
        label: l10n.languagePickerDownloading,
        child: SizedBox.square(
          dimension: _size,
          child: Center(
            child: SpinningRing(
              size: 18,
              stroke: 2.5,
              trackColor: c.border,
              activeColor: c.coral,
              duration: const Duration(milliseconds: 900),
            ),
          ),
        ),
      ),
      OfflineModelDownloaded() => _button(
        icon: Icons.offline_pin_rounded,
        color: c.coral,
        tooltip: l10n.languagePickerAvailableOffline,
        onPressed: onRemove,
      ),
      OfflineModelBuiltIn() => Tooltip(
        message: l10n.languagePickerAvailableOffline,
        child: SizedBox.square(
          dimension: _size,
          child: Icon(
            Icons.offline_pin_rounded,
            size: _iconSize,
            color: c.coral,
          ),
        ),
      ),
    };
  }

  Widget _button({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: _iconSize, color: color),
      constraints: const BoxConstraints.tightFor(width: _size, height: _size),
      padding: EdgeInsets.zero,
    );
  }
}
