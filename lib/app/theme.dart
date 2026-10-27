import 'package:flutter/material.dart';

import 'app_fonts.dart' as local_fonts;

class AppTheme {
  // Colors
  static const Color inkTeal = Color(0xFF244C5A);
  static const Color paper = Color(0xFFF4F7F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color hairline = Color(0xFFD9E1DF);
  static const Color textPrimary = Color(0xFF1B2A30);
  static const Color textSecondary = Color(0xFF5B676C);
  static const Color softMint = Color(0xFFE3F1EC);
  static const Color accentCoral = Color(0xFFC66551);
  static const Color error = Color(0xFFB42318);
  static const Color success = Color(0xFF1F7A4D);

  // Spacing (4px base unit)
  static const double spacingUnit = 4.0;
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;

  // Border radius
  static const double radius12 = 8.0;

  // Tap target size
  static const double tapTarget = 44.0;

  // Window constraints
  static const double minWindowWidth = 900.0;
  static const double minWindowHeight = 600.0;
  static const double compactHeaderHeight = 96.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: inkTeal,
        secondary: accentCoral,
        surface: surface,
        error: error,
      ),
      scaffoldBackgroundColor: paper,
      fontFamily: 'InstrumentSans',
      textTheme: _buildTextTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: inkTeal,
          side: const BorderSide(color: hairline),
          padding: const EdgeInsets.symmetric(
            horizontal: space16,
            vertical: space12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius12),
          ),
          minimumSize: const Size(tapTarget, tapTarget),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius12),
          side: const BorderSide(color: hairline),
        ),
      ),
      iconTheme: const IconThemeData(color: textPrimary, size: 24),
      focusColor: inkTeal.withValues(alpha: 0.12),
      highlightColor: inkTeal.withValues(alpha: 0.08),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      // Display - Newsreader (with fallback to serif)
      displayLarge: local_fonts
          .newsreader(
            fontSize: 57,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            height: 1.1,
          )
          .copyWith(fontFamilyFallback: ['Georgia', 'serif']),
      displayMedium: local_fonts
          .newsreader(
            fontSize: 45,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            height: 1.15,
          )
          .copyWith(fontFamilyFallback: ['Georgia', 'serif']),
      displaySmall: local_fonts
          .newsreader(
            fontSize: 36,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            height: 1.2,
          )
          .copyWith(fontFamilyFallback: ['Georgia', 'serif']),
      // Headline - Newsreader (with fallback to serif)
      headlineLarge: local_fonts
          .newsreader(
            fontSize: 32,
            fontWeight: FontWeight.w500,
            color: textPrimary,
            height: 1.2,
          )
          .copyWith(fontFamilyFallback: ['Georgia', 'serif']),
      headlineMedium: local_fonts
          .newsreader(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: textPrimary,
            height: 1.25,
          )
          .copyWith(fontFamilyFallback: ['Georgia', 'serif']),
      headlineSmall: local_fonts
          .newsreader(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: textPrimary,
            height: 1.3,
          )
          .copyWith(fontFamilyFallback: ['Georgia', 'serif']),
      // Title - Instrument Sans (with fallback to sans-serif)
      titleLarge: local_fonts
          .instrumentSans(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            height: 1.3,
          )
          .copyWith(fontFamilyFallback: ['Arial', 'sans-serif']),
      titleMedium: local_fonts
          .instrumentSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            height: 1.4,
          )
          .copyWith(fontFamilyFallback: ['Arial', 'sans-serif']),
      titleSmall: local_fonts
          .instrumentSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            height: 1.4,
          )
          .copyWith(fontFamilyFallback: ['Arial', 'sans-serif']),
      // Body - Instrument Sans (with fallback to sans-serif)
      bodyLarge: local_fonts
          .instrumentSans(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            height: 1.5,
          )
          .copyWith(fontFamilyFallback: ['Arial', 'sans-serif']),
      bodyMedium: local_fonts
          .instrumentSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            height: 1.5,
          )
          .copyWith(fontFamilyFallback: ['Arial', 'sans-serif']),
      bodySmall: local_fonts
          .instrumentSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: textSecondary,
            height: 1.5,
          )
          .copyWith(fontFamilyFallback: ['Arial', 'sans-serif']),
      // Label - Instrument Sans (with fallback to sans-serif)
      labelLarge: local_fonts
          .instrumentSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            height: 1.4,
          )
          .copyWith(fontFamilyFallback: ['Arial', 'sans-serif']),
      labelMedium: local_fonts
          .instrumentSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            height: 1.4,
          )
          .copyWith(fontFamilyFallback: ['Arial', 'sans-serif']),
      labelSmall: local_fonts
          .instrumentSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textSecondary,
            height: 1.4,
          )
          .copyWith(fontFamilyFallback: ['Arial', 'sans-serif']),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: space16,
        vertical: space16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius12),
        borderSide: const BorderSide(color: hairline, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius12),
        borderSide: const BorderSide(color: hairline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius12),
        borderSide: const BorderSide(color: inkTeal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius12),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius12),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      labelStyle: local_fonts
          .instrumentSans(
            fontSize: 14,
            color: textSecondary,
            fontWeight: FontWeight.w400,
          )
          .copyWith(fontFamilyFallback: ['Arial', 'sans-serif']),
      hintStyle: local_fonts
          .instrumentSans(
            fontSize: 14,
            color: textSecondary,
            fontWeight: FontWeight.w400,
          )
          .copyWith(fontFamilyFallback: ['Arial', 'sans-serif']),
      errorStyle: local_fonts
          .instrumentSans(
            fontSize: 12,
            color: error,
            fontWeight: FontWeight.w400,
          )
          .copyWith(fontFamilyFallback: ['Arial', 'sans-serif']),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: inkTeal,
        foregroundColor: surface,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: space24,
          vertical: space16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius12),
        ),
        textStyle: local_fonts
            .instrumentSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.4,
            )
            .copyWith(fontFamilyFallback: ['Arial', 'sans-serif']),
        minimumSize: const Size(tapTarget, tapTarget),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: inkTeal,
        padding: const EdgeInsets.symmetric(
          horizontal: space16,
          vertical: space12,
        ),
        textStyle: local_fonts
            .instrumentSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
            )
            .copyWith(fontFamilyFallback: ['Arial', 'sans-serif']),
        minimumSize: const Size(tapTarget, tapTarget),
      ),
    );
  }
}
