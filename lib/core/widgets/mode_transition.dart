import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// An [IndexedStack] that switches with the shared-axis motion of design
/// `Mode Transition`: the new child slides in from the side of the tab row it
/// was picked on while the old one slides out the other way. Every child stays
/// mounted and keeps its state. [ModeEntrance]s inside the new child play on
/// top of that.
class ModeTransitionStack extends StatefulWidget {
  const ModeTransitionStack({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  State<ModeTransitionStack> createState() => _ModeTransitionStackState();
}

class _ModeTransitionStackState extends State<ModeTransitionStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// The child sliding out, until the switch ends.
  int? _closing;

  /// How opaque [_closing] was when the switch began: under 1 when this switch
  /// cut its own opening short.
  double _closingOpacity = 1;

  /// 1 moving to a later child, -1 to an earlier one.
  int _step = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.modeTotal,
      value: 1,
    )..addStatusListener(_onStatusChanged);
  }

  @override
  void didUpdateWidget(ModeTransitionStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index == oldWidget.index) return;
    _closingOpacity = AppMotion.modeFadeIn.transform(_controller.value);
    _closing = oldWidget.index;
    _step = widget.index > oldWidget.index ? 1 : -1;
    _controller.forward(from: 0);
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) setState(() => _closing = null);
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_onStatusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final direction = isRtl ? -_step : _step;
    return Stack(
      children: [
        for (final (index, child) in widget.children.indexed)
          _panel(index, direction, child),
      ],
    );
  }

  /// Keeps one shape in every state, so no child ever loses its [State].
  Widget _panel(int index, int direction, Widget child) {
    final opening = index == widget.index;
    final closing = index == _closing;

    return Visibility(
      visible: opening || closing,
      maintainState: true,
      maintainAnimation: true,
      maintainSize: true,
      child: IgnorePointer(
        ignoring: closing,
        child: _EntranceScope(
          animation: opening ? _controller : kAlwaysCompleteAnimation,
          direction: direction,
          child: AnimatedBuilder(
            animation: _controller,
            child: child,
            builder: (context, child) {
              final t = _controller.value;
              final slide = AppMotion.modeSlide.transform(t);
              final shift = direction * AppMotion.modeShift;
              final (opacity, dx) = closing
                  ? (
                      _closingOpacity *
                          (1 - AppMotion.modeFadeOut.transform(t)),
                      -shift * slide,
                    )
                  : (AppMotion.modeFadeIn.transform(t), shift * (1 - slide));
              return Transform.translate(
                offset: Offset(dx, 0),
                child: Opacity(opacity: opacity, child: child),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EntranceScope extends InheritedWidget {
  const _EntranceScope({
    required this.animation,
    required this.direction,
    required super.child,
  });

  final Animation<double> animation;
  final int direction;

  @override
  bool updateShouldNotify(_EntranceScope oldWidget) =>
      animation != oldWidget.animation || direction != oldWidget.direction;
}

/// Plays [child] in, one [index] after another, when its [ModeTransitionStack]
/// child opens; rests in place otherwise and outside a stack.
class ModeEntrance extends StatelessWidget {
  const ModeEntrance({
    super.key,
    required this.index,
    this.offset,
    this.scale = 1,
    this.alignment = Alignment.center,
    required this.child,
  }) : assert(index >= 0 && index <= AppMotion.lastEntrance);

  /// Position in the stagger — later indexes start later.
  final int index;

  /// Where [child] starts from; by default the side the stack is opening from.
  final Offset? offset;

  /// The scale [child] starts at.
  final double scale;

  /// The point [child] scales around.
  final AlignmentGeometry alignment;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_EntranceScope>();
    if (scope == null) return child;

    final animation = scope.animation;
    final from = offset ?? Offset(scope.direction * AppMotion.entranceShift, 0);
    final slide = AppMotion.entranceSlide(index);
    final fade = AppMotion.entranceFade(index);

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final progress = slide.transform(animation.value);
        return Opacity(
          opacity: fade.transform(animation.value),
          child: Transform.translate(
            offset: from * (1 - progress),
            child: Transform.scale(
              scale: scale + (1 - scale) * progress,
              alignment: alignment,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
