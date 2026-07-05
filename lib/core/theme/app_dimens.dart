/// Design tokens — spacing, radii, sizes. Source: `Transly-AI-Design-System.md` §4–5.
abstract final class AppDimens {
  // ── Spacing ──
  static const double spaceXS = 4;
  static const double spaceS = 8; // inner element gaps
  static const double spaceM = 12; // gap between stacked cards
  static const double spaceL = 16; // screen h-padding (min)
  static const double spaceXL = 20; // screen h-padding (max)
  static const double space2XL = 24;
  static const double space3XL = 32;

  // ── Radii ──
  static const double radiusChip = 10; // icon chip / small
  static const double radiusChipL = 12;
  static const double radiusInput = 14; // input / search
  static const double radiusButton = 16; // primary button
  static const double radiusCard = 20; // card
  static const double radiusPill = 999; // pill / toggle

  // ── Component sizes ──
  static const double buttonHeight = 56; // 52–56
  static const double inputDockHeight = 56;
  static const double toggleTrackWidth = 50;
  static const double toggleTrackHeight = 30;
  static const double toggleKnobSize = 24;

  // ── Icons ──
  static const double iconS = 16;
  static const double iconM = 20;
  static const double iconL = 24; // 24×24 viewBox base

  // ── Avatar / logo ──
  static const double logoSize = 76;
  static const double avatarSize = 54;
  static const double micButtonSize = 84;
}
