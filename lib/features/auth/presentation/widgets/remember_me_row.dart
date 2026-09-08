import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';

/// "Remember me" checkbox + "Forgot password?" link row (design `01b · Sign
/// In`). The checkbox is a plain coral-filled box (not `Checkbox`, to match
/// the design's 20×20/radius-6 shape exactly) — a lightweight custom
/// [GestureDetector] rather than a new dependency.
class RememberMeRow extends StatelessWidget {
  const RememberMeRow({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onForgotPasswordTap,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onForgotPasswordTap;

  static const double _boxSize = 20;
  static const double _boxRadius = 6;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    // Both children are Flexible: at narrow widths or large text scales the
    // two labels together exceed the row, and an unconstrained Row would paint
    // overflow stripes rather than ellipsize.
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Semantics(
            checked: value,
            label: l10n.signInRememberMe,
            child: MergeSemantics(
              child: GestureDetector(
                onTap: () => onChanged(!value),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  // Lifts the 20px box toward a reachable tap target.
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: _boxSize,
                        height: _boxSize,
                        decoration: BoxDecoration(
                          color: value ? c.coral : Colors.transparent,
                          borderRadius: BorderRadius.circular(_boxRadius),
                          border: Border.all(
                            color: value ? c.coral : c.border,
                            width: 1.5,
                          ),
                        ),
                        child: value
                            ? const Icon(
                                Icons.check_rounded,
                                size: 12,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          l10n.signInRememberMe,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimens.spaceS),
        Flexible(
          child: Semantics(
            button: true,
            child: GestureDetector(
              onTap: onForgotPasswordTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  l10n.signInForgotPassword,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: textTheme.bodySmall?.copyWith(
                    color: c.coral,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
