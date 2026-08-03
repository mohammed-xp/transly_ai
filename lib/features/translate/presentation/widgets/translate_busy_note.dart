import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';

/// Centered sparkle + caption shown under the output card while a model
/// downloads or a translation runs (design `02b · Translating`).
class TranslateBusyNote extends StatelessWidget {
  const TranslateBusyNote({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.auto_awesome, size: 14, color: c.iconLine),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(fontSize: 12, color: c.textMuted),
          ),
        ),
      ],
    );
  }
}
