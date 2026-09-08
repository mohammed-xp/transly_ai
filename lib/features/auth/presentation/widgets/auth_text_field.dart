import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';

/// Labeled input field matching design `01b · Sign In`: a 13/600 caption
/// above a 54px-tall field, radius 14, with a coral focus ring
/// (`box-shadow 0 0 0 4px`). Reused for the email and password fields, so it
/// earns its place as a widget rather than being duplicated (CLAUDE.md §A-2).
///
/// [controller] and [focusNode] are owned by the screen's `State` — created
/// in `initState`, disposed in `dispose` — never built here (CLAUDE.md §B-7).
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.focusNode,
    required this.prefixIcon,
    required this.onChanged,
    this.obscureText = false,
    this.suffixIcon,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofillHints,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final IconData prefixIcon;
  final ValueChanged<String> onChanged;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;

  static const double _fieldHeight = 54;
  static const double _radius = AppDimens.radiusInput;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(AuthTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The node is owned by the caller; if it swaps one in, the focus-ring
    // listener has to follow it or the ring silently stops updating.
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_onFocusChange);
      widget.focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final isFocused = widget.focusNode.hasFocus;
    final hasError = widget.errorText != null;

    final borderColor = hasError
        ? Theme.of(context).colorScheme.error
        : c.coral;
    final radius = BorderRadius.circular(AuthTextField._radius);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: textTheme.titleSmall?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: 7),
        Container(
          height: AuthTextField._fieldHeight,
          decoration: BoxDecoration(
            color: isFocused ? c.surface : c.inputFill,
            borderRadius: radius,
            border: Border.all(
              color: hasError || isFocused ? borderColor : c.border,
              width: hasError || isFocused ? 1.5 : 1,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: borderColor.withValues(
                        alpha: Theme.of(context).brightness == Brightness.dark
                            ? 0.14
                            : 0.10,
                      ),
                      spreadRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              const SizedBox(width: 15),
              Icon(
                widget.prefixIcon,
                size: 19,
                color: hasError ? borderColor : c.textMuted,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  onChanged: widget.onChanged,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  autofillHints: widget.autofillHints,
                  onSubmitted: widget.onFieldSubmitted,
                  style: textTheme.bodyMedium?.copyWith(color: c.ink),
                  // The container above already paints the fill, border and
                  // focus ring. `border:` alone would not undo the app-wide
                  // `inputDecorationTheme`: `enabledBorder`/`focusedBorder`
                  // take precedence over it, so the themed outline would be
                  // drawn *inside* the container's, reading as a doubled,
                  // embossed edge — and `filled: true` would paint over the
                  // container's fill. Every slot is neutralised explicitly.
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: textTheme.bodyMedium?.copyWith(color: c.hint),
                    filled: false,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                ),
              ),
              if (widget.suffixIcon != null) ...[
                widget.suffixIcon!,
                const SizedBox(width: 12),
              ],
              if (widget.suffixIcon == null) const SizedBox(width: 15),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: textTheme.bodySmall?.copyWith(color: borderColor),
          ),
        ],
      ],
    );
  }
}
