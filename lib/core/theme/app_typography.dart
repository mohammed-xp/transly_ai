import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  static TextTheme textTheme(Color primary) => TextTheme(
        displayLarge: _ibm(size: 40, weight: FontWeight.w700, color: primary, letterSpacing: -0.4),
        headlineLarge: _ibm(size: 25, weight: FontWeight.w700, color: primary, letterSpacing: -0.25),
        headlineMedium: _ibm(size: 20, weight: FontWeight.w600, color: primary),
        titleLarge: _ibm(size: 17, weight: FontWeight.w600, color: primary),
        titleMedium: _ibm(size: 16, weight: FontWeight.w600, color: primary),
        titleSmall: _ibm(size: 13, weight: FontWeight.w600, color: primary),
        bodyLarge: _ibm(size: 17, weight: FontWeight.w400, color: primary, height: 1.5),
        bodyMedium: _ibm(size: 16, weight: FontWeight.w400, color: primary, height: 1.45),
        bodySmall: _ibm(size: 14, weight: FontWeight.w400, color: primary, height: 1.4),
        labelLarge: _ibm(size: 13, weight: FontWeight.w600, color: primary, letterSpacing: 0.04),
        labelMedium: _ibm(size: 12, weight: FontWeight.w600, color: primary, letterSpacing: 0.05),
        labelSmall: _ibm(size: 11, weight: FontWeight.w500, color: primary),
      );

  static TextStyle _ibm({
    required double size,
    required FontWeight weight,
    required Color color,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.ibmPlexSansArabic(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle labelCaps(Color color) => GoogleFonts.ibmPlexSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.05,
      );
}

extension TextStyleX on TextStyle {
  TextStyle withColor(Color c) => copyWith(color: c);
  TextStyle light() => copyWith(fontWeight: FontWeight.w300);
  TextStyle medium() => copyWith(fontWeight: FontWeight.w500);
  TextStyle semiBold() => copyWith(fontWeight: FontWeight.w600);
  TextStyle bold() => copyWith(fontWeight: FontWeight.w700);
}
