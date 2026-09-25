import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_dimens.dart';
import 'app_toast.dart';
import 'app_toast_card.dart';

/// Hosts at most one toast over [child], pinned to its bottom edge. A new
/// toast replaces the current one.
///
/// Toasts go to the nearest scope, so nest one wherever they need a different
/// anchor: `HomeShell` puts one above its input dock, the app root holds the
/// fallback. A toast is disposed with its scope, so a persistent one can't
/// follow the user onto the next screen.
class AppToastScope extends StatefulWidget {
  const AppToastScope({
    super.key,
    required this.child,
    this.bottomSpacing = AppDimens.spaceL,
    this.avoidSystemInsets = true,
  });

  final Widget child;

  /// Gap between the toast and the scope's bottom edge.
  final double bottomSpacing;

  /// Adds the keyboard / system-bar inset to [bottomSpacing]. Turn off when
  /// the scope already ends above them (e.g. above the home input dock).
  final bool avoidSystemInsets;

  static AppToastScopeState? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_AppToastScopeMarker>()?.state;

  @override
  State<AppToastScope> createState() => AppToastScopeState();
}

class AppToastScopeState extends State<AppToastScope> {
  AppToastData? _data;
  int _serial = 0;

  void show(AppToastData data) {
    setState(() {
      _data = data;
      _serial++;
    });
  }

  void hide() {
    if (_data != null) setState(() => _data = null);
  }

  void _remove(int serial) {
    if (serial == _serial && _data != null) setState(() => _data = null);
  }

  double _bottomOffset(BuildContext context) {
    if (!widget.avoidSystemInsets) return widget.bottomSpacing;
    final systemInset = math.max(
      MediaQuery.viewInsetsOf(context).bottom,
      MediaQuery.viewPaddingOf(context).bottom,
    );
    return systemInset + widget.bottomSpacing;
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final serial = _serial;

    return _AppToastScopeMarker(
      state: this,
      child: Stack(
        fit: StackFit.passthrough,
        clipBehavior: Clip.none,
        children: [
          widget.child,
          if (data != null)
            PositionedDirectional(
              start: AppDimens.spaceL,
              end: AppDimens.spaceL,
              bottom: _bottomOffset(context),
              child: _ToastLifecycle(
                key: ValueKey(serial),
                data: data,
                onDismissed: () => _remove(serial),
              ),
            ),
        ],
      ),
    );
  }
}

class _AppToastScopeMarker extends InheritedWidget {
  const _AppToastScopeMarker({required this.state, required super.child});

  final AppToastScopeState state;

  @override
  bool updateShouldNotify(_AppToastScopeMarker oldWidget) => false;
}

/// Drives one toast: rise-and-fade entrance, countdown to auto-dismiss,
/// swipe-down and action dismissal.
class _ToastLifecycle extends StatefulWidget {
  const _ToastLifecycle({
    super.key,
    required this.data,
    required this.onDismissed,
  });

  final AppToastData data;
  final VoidCallback onDismissed;

  @override
  State<_ToastLifecycle> createState() => _ToastLifecycleState();
}

class _ToastLifecycleState extends State<_ToastLifecycle>
    with TickerProviderStateMixin {
  static const Duration _entranceDuration = Duration(milliseconds: 220);
  static const double _riseDistance = 16;

  late final AnimationController _entrance;
  late final CurvedAnimation _entranceCurve;
  AnimationController? _countdown;
  Animation<double>? _remaining;
  bool _countdownResolved = false;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: _entranceDuration)
      ..forward();
    _entranceCurve = CurvedAnimation(
      parent: _entrance,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_countdownResolved) return;
    _countdownResolved = true;

    final duration = widget.data.autoDismissAfter;
    // Like SnackBar: screen-reader users need time to reach the action.
    final holdForAction =
        widget.data.hasAction && MediaQuery.accessibleNavigationOf(context);
    if (duration == null || holdForAction) return;

    final countdown = AnimationController(vsync: this, duration: duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _dismiss();
      })
      ..forward();
    _countdown = countdown;
    _remaining = ReverseAnimation(countdown);
  }

  void _dismiss() {
    if (_dismissing) return;
    _dismissing = true;
    _countdown?.stop();
    _entrance.reverse().then((_) {
      if (mounted) widget.onDismissed();
    });
  }

  void _handleAction() {
    widget.data.onAction?.call();
    _dismiss();
  }

  @override
  void dispose() {
    _countdown?.dispose();
    _entranceCurve.dispose();
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const ValueKey('app-toast'),
      direction: DismissDirection.down,
      resizeDuration: null,
      onDismissed: (_) => widget.onDismissed(),
      child: FadeTransition(
        opacity: _entranceCurve,
        child: AnimatedBuilder(
          animation: _entranceCurve,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, _riseDistance * (1 - _entranceCurve.value)),
            child: child,
          ),
          child: Semantics(
            container: true,
            liveRegion: true,
            onDismiss: _dismiss,
            child: AppToastCard(
              data: widget.data,
              remaining: _remaining,
              onAction: widget.data.hasAction ? _handleAction : null,
            ),
          ),
        ),
      ),
    );
  }
}
