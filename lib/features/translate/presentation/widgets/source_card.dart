import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import 'speaker_button.dart';

/// Editable source card: language label, a speaker button, and the input field
/// the user types into (design `02 · Translate`). Owns its [TextEditingController]
/// and keeps it in sync with external state changes (e.g. language swap).
class SourceCard extends StatefulWidget {
  const SourceCard({
    super.key,
    required this.isDark,
    required this.language,
    required this.text,
    required this.hintText,
    required this.textDirection,
    required this.onChanged,
    required this.onSubmitted,
    required this.onSpeak,
  });

  final bool isDark;
  final String language;

  /// Source text from cubit state. When it diverges from the controller (swap),
  /// the field is resynced without firing [onChanged].
  final String text;
  final String hintText;
  final TextDirection textDirection;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  /// Invoked when the speaker icon is tapped; null disables it (nothing to speak).
  final VoidCallback? onSpeak;

  @override
  State<SourceCard> createState() => _SourceCardState();
}

class _SourceCardState extends State<SourceCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(covariant SourceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Resync only on external change (swap) — never echo the user's own typing.
    if (widget.text != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.text,
        selection: TextSelection.collapsed(offset: widget.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final surface =
        widget.isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = widget.isDark ? AppColors.borderDark : AppColors.borderLight;
    final labelColor =
        widget.isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final iconColor =
        widget.isDark ? AppColors.iconLineDark : AppColors.captionMutedLight;
    final inkColor =
        widget.isDark ? AppColors.textPrimaryDark : AppColors.inkLight;
    final hintColor =
        widget.isDark ? AppColors.textMutedDark : AppColors.captionMutedLight;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.language,
                style: textTheme.titleSmall?.copyWith(color: labelColor),
              ),
              SpeakerButton(
                icon: Icons.volume_up_outlined,
                color: iconColor,
                onTap: widget.onSpeak,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceS + 2),
          TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            onSubmitted: (_) => widget.onSubmitted(),
            textInputAction: TextInputAction.done,
            textDirection: widget.textDirection,
            maxLines: null,
            minLines: 1,
            cursorColor: widget.isDark ? AppColors.accentDark : AppColors.primary,
            style: textTheme.bodyLarge?.copyWith(color: inkColor, height: 1.45),
            decoration: InputDecoration(
              isDense: true,
              // The card is the field's chrome — suppress the app-level
              // InputDecorationTheme (fill + colored outline per state).
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: widget.hintText,
              hintStyle:
                  textTheme.bodyLarge?.copyWith(color: hintColor, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
