import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';

/// "Or continue with" divider above the social auth row.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final textTheme = Theme.of(context).textTheme;

    // The label is Flexible so a long translation or a large text scale
    // ellipsizes instead of overflowing the row.
    return Row(
      children: [
        Expanded(child: Divider(color: c.border, height: 1)),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: c.textMuted),
            ),
          ),
        ),
        Expanded(child: Divider(color: c.border, height: 1)),
      ],
    );
  }
}
