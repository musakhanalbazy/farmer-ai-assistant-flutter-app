import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_color.dart';

/// Typography scale from DESIGN.md — Nunito Sans for display/headline
/// (friendly, approachable), Inter for body/label (max readability for
/// technical data like soil pH or chemical ratios).
class AppTypography {
  static TextStyle displayLg({Color color = AppColors.onSurface}) =>
      GoogleFonts.nunitoSans(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        height: 48 / 40,
        letterSpacing: -0.02 * 40,
        color: color,
      );

  static TextStyle headlineLg({Color color = AppColors.onSurface}) =>
      GoogleFonts.nunitoSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        color: color,
      );

  /// Mobile variant of headline-lg.
  static TextStyle headlineLgMobile({Color color = AppColors.onSurface}) =>
      GoogleFonts.nunitoSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 36 / 28,
        color: color,
      );

  static TextStyle headlineMd({Color color = AppColors.onSurface}) =>
      GoogleFonts.nunitoSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
        color: color,
      );

  static TextStyle bodyLg({Color color = AppColors.onSurface}) =>
      GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: color,
      );

  static TextStyle bodyMd({Color color = AppColors.onSurface}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: color,
      );

  static TextStyle labelMd({Color color = AppColors.onSurface}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        letterSpacing: 0.01 * 14,
        color: color,
      );

  static TextStyle labelSm({Color color = AppColors.onSurfaceVariant}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        color: color,
      );
}
