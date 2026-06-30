import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFFFF5836);
  static const Color primaryDark = Color(0xFFC0461F);
  static const Color gradientStart = Color(0xFFFF7A4D);
  static const Color gradientMid = Color(0xFFF5421C);
  static const Color gradientEnd = Color(0xFFD5300F);

  // Light theme surfaces
  static const Color backgroundLight = Color(0xFFF6F7F9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFECEDF1);
  static const Color outputBgLight = Color(0xFFFFF4F0);
  static const Color outputBgLight2 = Color(0xFFFFEAE2);
  static const Color outputBorderLight = Color(0xFFFFD8C9);

  // Dark theme surfaces
  static const Color backgroundDark = Color(0xFF0E0F12);
  static const Color surfaceDark = Color(0xFF1B1D22);
  static const Color borderDark = Color(0xFF2A2D34);

  // Text — light
  static const Color textPrimaryLight = Color(0xFF16181D);
  static const Color textSecondaryLight = Color(0xFF5A6072);
  static const Color textMutedLight = Color(0xFF9AA0AE);

  // Text — dark
  static const Color textPrimaryDark = Color(0xFFF3F4F6);
  static const Color textMutedDark = Color(0xFF7C828E);

  // Miscellaneous
  static const Color chipBgLight = Color(0xFFF2F3F6);
  static const Color divider = Color(0xFFF1F2F5);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientMid],
  );

  static const LinearGradient onboardingGradient = LinearGradient(
    begin: Alignment(0, -1),
    end: Alignment(-0.2, 1),
    colors: [gradientStart, gradientMid, gradientEnd],
    stops: [0.0, 0.52, 1.0],
  );
}
