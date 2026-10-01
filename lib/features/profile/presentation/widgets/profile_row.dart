import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';

class ProfileRow extends StatelessWidget {
  const ProfileRow({
    super.key,
    required this.label,
    this.value,
    this.valueDirection,
    this.trailing,
    this.onTap,
  });

  final String label;
  final String? value;

  final TextDirection? valueDirection;

  final Widget? trailing;
  final VoidCallback? onTap;

  static const double _height = 50;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;
    final value = this.value;
    final trailing = this.trailing;

    final labelText = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textTheme.bodyMedium?.copyWith(
        fontSize: 15,
        color: value == null ? c.ink : c.textSecondary,
      ),
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.spaceL),
        child: SizedBox(
          height: _height,
          child: Row(
            children: [
              if (value == null)
                Expanded(child: labelText)
              else ...[
                // Flexible(flex: 2, child: labelText),
                labelText,
                const SizedBox(width: AppDimens.spaceM),
                Expanded(
                  // flex: 3,
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      value,
                      textDirection: valueDirection,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: c.ink,
                      ),
                    ),
                  ),
                ),
              ],
              if (trailing != null) ...[
                const SizedBox(width: AppDimens.spaceM),
                trailing,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Forward chevron for rows that open something. The icon mirrors itself in
/// RTL, so it points left in Arabic like the design.
class ProfileRowChevron extends StatelessWidget {
  const ProfileRowChevron({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right_rounded,
      size: AppDimens.iconM,
      color: context.palette.iconLine,
    );
  }
}
