import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../../../../l10n/app_localizations.dart';

class LanguageSearchField extends StatelessWidget {
  const LanguageSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusInput),
      borderSide: BorderSide(color: c.border),
    );

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      autocorrect: false,
      style: textTheme.bodyMedium?.copyWith(fontSize: 15, color: c.ink),
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.languagePickerSearchHint,
        hintStyle: textTheme.bodyMedium?.copyWith(
          fontSize: 15,
          color: c.textMuted,
        ),
        isDense: true,
        filled: true,
        fillColor: c.screenBackground,
        prefixIcon: Center(
          widthFactor: 1,
          child: AppSvgIcon(AppIcons.search, size: 18, color: c.textMuted),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 42,
          minHeight: 48,
        ),
        contentPadding: const EdgeInsetsDirectional.only(
          top: 13,
          bottom: 13,
          end: 14,
        ),
        border: border,
        enabledBorder: border,
      ),
    );
  }
}
