import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../../../../l10n/app_localizations.dart';

/// "Read translations aloud" switch card on the empty conversation tab.
class ReadAloudRow extends StatelessWidget {
  const ReadAloudRow({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  static const double _minHeight = 60;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;
    final radius = BorderRadius.circular(AppDimens.radiusButton);

    return MergeSemantics(
      child: Material(
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: c.border),
        ),
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _minHeight),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppDimens.spaceL,
                10,
                AppDimens.spaceM,
                10,
              ),
              child: Row(
                children: [
                  AppSvgIcon(
                    AppIcons.speaker,
                    size: AppDimens.iconM,
                    color: c.coral,
                  ),
                  const SizedBox(width: AppDimens.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.conversationReadAloud,
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: c.ink,
                          ),
                        ),
                        Text(
                          l10n.conversationReadAloudBody,
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0,
                            height: 1.4,
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.spaceM),
                  Switch(value: value, onChanged: onChanged),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
