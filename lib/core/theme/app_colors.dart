import 'package:flutter/material.dart';

/// Design tokens — colors. Source: `Transly-AI-Design-System.md` §1.
abstract final class AppColors {
  // ── Brand (Coral) ──
  static const Color primary = Color(0xFFFF5836); // main brand (light)
  static const Color deep = Color(0xFFF5421C); // gradient end, pressed
  static const Color accentDark = Color(0xFFFF6A45); // primary accent (dark)
  static const Color accentDark2 = Color(0xFFFF8A66); // secondary accent (dark)
  static const Color gradientStart = Color(0xFFFF7A4D);
  static const Color gradientDeepEnd = Color(0xFFD5300F); // onboarding hero end
  static const Color brandShadow = Color(
    0xFF781400,
  ); // deep coral drop-shadow tint

  // ── Coral tints (light) ──
  static const Color outputBgLight = Color(0xFFFFF4F0); // output/icon-chip bg
  static const Color outputBgLight2 = Color(0xFFFFEAE2); // output gradient end
  static const Color tintBorderLight = Color(0xFFFFD8C9);
  static const Color spinnerTrackLight = Color(
    0xFFFFE0D5,
  ); // splash loader track
  static const Color rtlLabelLight = Color(0xFFC0461F); // Arabic label on light
  static const Color progressTrackLight = Color(
    0xFFFFE8E0,
  ); // language-bar progress track

  // ── Light neutrals ──
  static const Color inkLight = Color(0xFF16181D); // primary text
  static const Color textSecondaryLight = Color(0xFF5A6072);
  static const Color textMutedLight = Color(0xFF9AA0AE);
  static const Color borderLight = Color(0xFFECEDF1);
  static const Color captionMutedLight = Color(0xFFC2C6D0); // faint captions
  static const Color dividerLight = Color(0xFFF1F2F5);
  static const Color backgroundLight = Color(0xFFF6F7F9); // app bg
  static const Color chipBgLight = Color(0xFFF2F3F6);
  static const Color surfaceLight = Color(0xFFFFFFFF); // cards, docks

  // ── Dark neutrals ──
  static const Color backgroundDark = Color(0xFF0E0F12); // app bg
  static const Color surfaceDark = Color(0xFF1B1D22); // cards, docks, inputs
  static const Color chipBgDark = Color(0xFF26282E);
  static const Color borderDark = Color(0xFF2A2D34);
  static const Color textPrimaryDark = Color(0xFFF3F4F6);
  static const Color textSecondaryDark = Color(0xFF969CA8);
  static const Color textMutedDark = Color(0xFF7C828E);
  static const Color iconLineDark = Color(0xFF5A5F69);

  // ── Shadows (light surfaces) ──
  static const Color cardShadowLight = Color(0x0A141928); // subtle card lift
  static const Color dockShadowLight = Color(0x0F141928); // floating dock lift

  // ── Toggle (off track) ──
  static const Color toggleTrackOffLight = Color(0xFFE6E8ED);
  static const Color toggleTrackOffDark = borderDark;

  // ── Feedback ──
  static const Color error = Color(0xFFD32F2F);

  /// Buttons, mic, logo, avatars — `linear-gradient(150deg, #FF7A4D, #F5421C)`.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment(-0.5, -1),
    end: Alignment(0.5, 1),
    colors: [gradientStart, deep],
  );
}
