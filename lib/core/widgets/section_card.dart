import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_palette.dart';

/// Section caption above a rounded card whose [rows] are separated by
/// hairline dividers (designs `12 · Profile` and the offline packs screen).
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.spaceS),
          child: Text(
            title,
            style: textTheme.labelMedium?.copyWith(color: c.textMuted),
          ),
        ),
        const SizedBox(height: AppDimens.spaceS),
        Material(
          color: c.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusCard),
            side: BorderSide(color: c.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    indent: AppDimens.spaceL,
                    endIndent: AppDimens.spaceL,
                  ),
                rows[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
