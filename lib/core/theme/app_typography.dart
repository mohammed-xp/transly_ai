import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens — typography. Source: `Transly-AI-Design-System.md` §2.
///
/// Font: IBM Plex Sans Arabic (Arabic + Latin). Weights 300–700.
abstract final class AppTypography {
  /// Material [TextTheme] mapped to the design scale, tinted with [textColor].
  static TextTheme textTheme(Color textColor) => TextTheme(
    // Display 40 / 700 — onboarding hero
    displayLarge: _font(40, FontWeight.w700, textColor, letterSpacing: -0.4),
    // Heading 25 / 700 — screen titles
    headlineLarge: _font(25, FontWeight.w700, textColor, letterSpacing: -0.25),
    headlineMedium: _font(20, FontWeight.w600, textColor),
    titleLarge: _font(17, FontWeight.w600, textColor),
    titleMedium: _font(16, FontWeight.w600, textColor),
    // Caption 13 / 600
    titleSmall: _font(13, FontWeight.w600, textColor, letterSpacing: 0.04),
    // Body L 20 / 400 — source/translation text
    bodyLarge: _font(20, FontWeight.w400, textColor, height: 1.5),
    // Body 16 / 400 — default
    bodyMedium: _font(16, FontWeight.w400, textColor, height: 1.45),
    bodySmall: _font(14, FontWeight.w400, textColor, height: 1.4),
    // Caption / labels — often UPPERCASE, letter-spacing .04–.05em
    labelLarge: _font(13, FontWeight.w600, textColor, letterSpacing: 0.04),
    labelMedium: _font(12, FontWeight.w600, textColor, letterSpacing: 0.05),
    // Micro 11 / 500 — tags, hints
    labelSmall: _font(11, FontWeight.w500, textColor),
  );

  static TextStyle _font(
    double size,
    FontWeight weight,
    Color color, {
    double? height,
    double? letterSpacing,
  }) => GoogleFonts.ibmPlexSansArabic(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}
