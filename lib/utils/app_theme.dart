import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_color.dart';
import 'app_typography.dart';

/// App-wide theme for the "Agri-Precision Naturalist" design system.
/// Applied once in MaterialApp so every screen inherits pill buttons,
/// 24px-radius cards, canopy-tinted shadows, and the Nunito Sans /
/// Inter type pairing by default — screens that hard-code their own
/// styling still render, but new/updated widgets should prefer this.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: const ColorScheme.light(
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),

      // Inter is the workhorse body/data font; Nunito Sans is layered on
      // top for display/headline styles below.
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: AppTypography.displayLg(),
        headlineLarge: AppTypography.headlineLg(),
        headlineMedium: AppTypography.headlineMd(),
        bodyLarge: AppTypography.bodyLg(),
        bodyMedium: AppTypography.bodyMd(),
        labelLarge: AppTypography.labelMd(),
        labelSmall: AppTypography.labelSm(),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineMd(),
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),

      // Primary: pill-shaped, forest green, 56px tall, white text.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.outlineVariant,
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: const StadiumBorder(),
          elevation: 0,
          textStyle: AppTypography.labelMd(color: AppColors.onPrimary),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: const StadiumBorder(),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: AppTypography.labelMd(color: AppColors.primary),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.labelMd(color: AppColors.primary),
        ),
      ),

      // Cards: white, 24px corner radius, soft canopy-tinted shadow,
      // faint forest-green border per DESIGN.md.
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.primary.withOpacity(0.1)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        labelStyle: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
        hintStyle: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.surface),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.surface),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),

      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surfaceContainerHighest,
        labelStyle: AppTypography.labelSm(color: AppColors.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        side: BorderSide.none,
      ),

      dividerTheme: const DividerThemeData(color: AppColors.outlineVariant, thickness: 1),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceContainerHighest,
      ),
    );
  }

  /// Soft, long-reaching, green-tinted ambient shadow (DESIGN.md
  /// Elevation — Level 1 static cards).
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: AppColors.primaryContainer.withOpacity(0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  /// Level 2 — floating action buttons / active modals.
  static List<BoxShadow> get floatingShadow => [
        BoxShadow(
          color: AppColors.primaryContainer.withOpacity(0.14),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ];
}
