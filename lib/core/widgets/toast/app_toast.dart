import 'package:flutter/material.dart';

import 'app_toast_scope.dart';

/// Visual family of a toast — picks the icon-chip style (design `07 · Toast`).
enum AppToastType {
  /// Coral-tinted chip — confirmations (copied, saved).
  success,

  /// Muted chip — informational or reversible actions (deleted, coming soon).
  neutral,

  /// Solid coral chip — failures. Stays until dismissed.
  error,

  /// Brand-gradient chip — AI suggestions.
  ai,
}

@immutable
class AppToastData {
  const AppToastData({
    required this.message,
    this.subtitle,
    this.type = AppToastType.success,
    this.icon,
    this.highlight,
    this.actionLabel,
    this.onAction,
  }) : assert(
         (actionLabel == null) == (onAction == null),
         'actionLabel and onAction must be provided together.',
       );

  final String message;
  final String? subtitle;
  final AppToastType type;

  /// Falls back to a per-[type] default when null.
  final IconData? icon;

  /// A substring of [message] drawn in the accent color. Passed as a
  /// substring (not split spans) so each locale can place it anywhere.
  final String? highlight;

  final String? actionLabel;
  final VoidCallback? onAction;

  bool get hasAction => actionLabel != null;

  /// Null means the toast stays until the user dismisses it.
  Duration? get autoDismissAfter => switch (type) {
    AppToastType.error => null,
    _ when hasAction => const Duration(seconds: 5),
    _ => const Duration(seconds: 3),
  };

  IconData get resolvedIcon =>
      icon ??
      switch (type) {
        AppToastType.success => Icons.check_rounded,
        AppToastType.neutral => Icons.info_outline_rounded,
        AppToastType.error => Icons.error_outline_rounded,
        AppToastType.ai => Icons.auto_awesome_rounded,
      };
}

/// Entry point for showing toasts. Resolves the nearest [AppToastScope], so
/// a toast lands in the right spot for the calling screen (e.g. above the
/// home input dock).
abstract final class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    String? subtitle,
    AppToastType type = AppToastType.success,
    IconData? icon,
    String? highlight,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _scope(context)?.show(
      AppToastData(
        message: message,
        subtitle: subtitle,
        type: type,
        icon: icon,
        highlight: highlight,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }

  static void hide(BuildContext context) => _scope(context)?.hide();

  static AppToastScopeState? _scope(BuildContext context) {
    final scope = AppToastScope.maybeOf(context);
    assert(scope != null, 'No AppToastScope above this context.');
    return scope;
  }
}
