import 'package:flutter/material.dart';

import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';

class RecentLanguageChips extends StatelessWidget {
  const RecentLanguageChips({
    super.key,
    required this.languages,
    required this.selected,
    required this.onPick,
  });

  final List<LanguageEntity> languages;
  final LanguageEntity selected;
  final ValueChanged<LanguageEntity> onPick;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (index, language) in languages.indexed) ...[
            if (index > 0) const SizedBox(width: AppDimens.spaceS),
            _Chip(
              label: language.nativeName,
              isSelected: language == selected,
              onTap: () => onPick(language),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final radius = BorderRadius.circular(AppDimens.radiusPill);

    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected ? c.coral : c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: isSelected ? c.coral : c.border),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : c.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
