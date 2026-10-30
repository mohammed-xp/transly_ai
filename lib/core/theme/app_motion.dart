import 'package:flutter/animation.dart';

/// Motion tokens for switching between the home shell's tabs. Source: design
/// `Mode Transition`.
abstract final class AppMotion {
  static const double _totalMs = 840;

  // ── Panels ──
  static const Duration modeSwitch = Duration(milliseconds: 460);
  static const Duration modeTotal = Duration(
    milliseconds: 840,
  ); // outlasts the last entrance
  static const Curve modeCurve = Cubic(.22, .8, .24, 1);
  static const double modeShift = 48;
  static const Interval modeSlide = Interval(
    0,
    460 / _totalMs,
    curve: modeCurve,
  );
  static const Interval modeFadeIn = Interval(
    0,
    322 / _totalMs,
    curve: Curves.ease,
  );
  static const Interval modeFadeOut = Interval(
    0,
    253 / _totalMs,
    curve: Curves.ease,
  );

  // ── Entrances inside a panel ──
  static const int lastEntrance = 4;
  static const double entranceShift = 28;
  static const Curve entranceCurve = Cubic(.2, .9, .3, 1.08);

  static Interval entranceSlide(int index) =>
      _entrance(index, 575, entranceCurve);

  static Interval entranceFade(int index) => _entrance(index, 414, Curves.ease);

  static Interval _entrance(int index, int lengthMs, Curve curve) {
    final startMs = 40 + 55 * index;
    return Interval(
      startMs / _totalMs,
      (startMs + lengthMs) / _totalMs,
      curve: curve,
    );
  }

  // ── Header kicker ──
  static const double kickerShift = 10;
  static const Interval kickerFadeIn = Interval(0, .8, curve: Curves.ease);
  static const Interval kickerFadeOut = Interval(
    .2,
    1,
    curve: FlippedCurve(Curves.ease),
  );

  // ── Dock ──
  static const Duration dockColor = Duration(milliseconds: 276);
  static const Curve popCurve = Cubic(.34, 1.56, .64, 1);
  static const double shrunkScale = .4;
  static const Duration micIn = Duration(milliseconds: 506);
  static const Duration micFadeIn = Duration(milliseconds: 230);
  static const Duration micOut = Duration(milliseconds: 322);
  static const Duration micFadeOut = Duration(milliseconds: 184);
}
