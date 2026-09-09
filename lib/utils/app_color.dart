import 'package:flutter/material.dart';

/// Central color palette — "Agri-Precision Naturalist" design system.
/// Deep forest green + harvest gold on a soft cream background, per
/// DESIGN.md. Existing field names are kept so every screen that already
/// references AppColors.* re-themes automatically; new tokens are added
/// alongside for direct design-system access.
class AppColors {
  // --- Legacy-named aliases (kept so existing call sites re-theme) ---
  static const Color primaryDark = primary;
  static const Color accentGold = secondaryContainer;
  static const Color background = surface;
  static const Color cardWhite = surfaceContainerLowest;
  static const Color textMuted = onSurfaceVariant;
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = secondaryContainer;
  static const Color danger = error;
  static const Color dangerBg = errorContainer;
  static const Color accent2 = surfaceContainerHighest;

  // --- Design tokens (from DESIGN.md) ---
  static const Color surface = Color(0xFFF7FAF5);
  static const Color surfaceDim = Color(0xFFD8DBD6);
  static const Color surfaceBright = Color(0xFFF7FAF5);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF1F4F0);
  static const Color surfaceContainer = Color(0xFFECEFEA);
  static const Color surfaceContainerHigh = Color(0xFFE6E9E4);
  static const Color surfaceContainerHighest = Color(0xFFE0E3DF);
  static const Color onSurface = Color(0xFF191C1A);
  static const Color onSurfaceVariant = Color(0xFF414844);
  static const Color inverseSurface = Color(0xFF2D312E);
  static const Color inverseOnSurface = Color(0xFFEFF2ED);
  static const Color outline = Color(0xFF717973);
  static const Color outlineVariant = Color(0xFFC1C8C2);
  static const Color surfaceTint = Color(0xFF3F6653);

  static const Color primary = Color(0xFF012D1D);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1B4332);
  static const Color onPrimaryContainer = Color(0xFF86AF99);
  static const Color inversePrimary = Color(0xFFA5D0B9);

  static const Color secondary = Color(0xFF805600);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFDBA4D);
  static const Color onSecondaryContainer = Color(0xFF704B00);

  static const Color tertiary = Color(0xFF262622);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF3C3C37);
  static const Color onTertiaryContainer = Color(0xFFA8A6A0);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color primaryFixed = Color(0xFFC1ECD4);
  static const Color primaryFixedDim = Color(0xFFA5D0B9);
  static const Color onPrimaryFixed = Color(0xFF002114);
  static const Color onPrimaryFixedVariant = Color(0xFF274E3D);

  static const Color secondaryFixed = Color(0xFFFFDDB0);
  static const Color secondaryFixedDim = Color(0xFFFDBA4D);
  static const Color onSecondaryFixed = Color(0xFF281800);
  static const Color onSecondaryFixedVariant = Color(0xFF614000);

  static const Color tertiaryFixed = Color(0xFFE5E2DB);
  static const Color tertiaryFixedDim = Color(0xFFC9C6C0);
  static const Color onTertiaryFixed = Color(0xFF1C1C18);
  static const Color onTertiaryFixedVariant = Color(0xFF474742);

  /// Ambient, canopy-tinted shadow used for card elevation (Level 1).
  static const Color shadowAmbient = Color(0x141B4332); // rgba(27,67,50,0.08)
}
