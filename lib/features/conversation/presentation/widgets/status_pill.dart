import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';

/// Centered pill saying what the mic is doing — "Detecting language…" while
/// recording, "Translating…" after — with an optional [caption] under it
/// (design `Conversation v2 · Detecting`).
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.leading,
    required this.label,
    this.caption,
  });

  final Widget leading;
  final String label;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;
    final caption = this.caption;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
              border: Border.all(color: c.coral, width: 1.5),
              boxShadow: [BoxShadow(color: c.focusRing, spreadRadius: 4)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                leading,
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      color: c.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 6),
            Text(
              caption,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
                color: c.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
