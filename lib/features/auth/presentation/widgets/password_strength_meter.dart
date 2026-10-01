import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/password_strength.dart';
import '../utils/auth_l10n.dart';

/// Four-segment strength bar with its label (design `01c · Sign Up`).
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.strength});

  final PasswordStrength strength;

  static const int _segments = 4;
  static const double _segmentHeight = 4;
  static const double _segmentGap = 5;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final label = passwordStrengthLabel(context, strength);
    final filled = strength.index + 1;
    final color = switch (strength) {
      PasswordStrength.weak => Theme.of(context).colorScheme.error,
      PasswordStrength.fair => c.coral,
      PasswordStrength.strong || PasswordStrength.veryStrong => c.success,
    };

    return Semantics(
      label: AppLocalizations.of(context)!.signUpPasswordStrengthLabel(label),
      excludeSemantics: true,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                for (var i = 0; i < _segments; i++) ...[
                  if (i > 0) const SizedBox(width: _segmentGap),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: _segmentHeight,
                      decoration: BoxDecoration(
                        color: i < filled ? color : c.border,
                        borderRadius: BorderRadius.circular(_segmentHeight / 2),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
