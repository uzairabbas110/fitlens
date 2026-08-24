import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  /// Signature brand typography style inspired by luxury modern display fonts
  static TextStyle brandHeadingStyle({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    double letterSpacing = -0.5,
  }) {
    return GoogleFonts.montserratAlternates(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static ThemeData get lightTheme {
    // Luxury Fashion Palette
    const Color primaryColor = Color(0xFF7E3B50); 
    const Color onPrimary = Colors.white;
    const Color primaryContainer = Color(0xFF9B5268);
    const Color onPrimaryContainer = Color(0xFFF9EAE1);

    const Color secondaryColor = Color(0xFF333333); 
    const Color onSecondary = Colors.white;
    const Color secondaryContainer = Color(0xFFF5EFEB); 

    const Color tertiaryColor = Color(0xFFE8DCCD); 
    const Color backgroundColor = Color(0xFFFBF8F5); 
    const Color surfaceColor = Color(0xFFFFFFFF); 
    const Color onSurfaceColor = Color(0xFF1E1E1E); 
    const Color errorColor = Color(0xFFBA1A1A);
    const Color outlineColor = Color(0xFFE0D5CF);

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondaryColor,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        tertiary: tertiaryColor,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
        error: errorColor,
        onError: Colors.white,
        outline: outlineColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.quicksandTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.montserratAlternates(
          fontWeight: FontWeight.w800,
          fontSize: 40,
          letterSpacing: -0.8,
          color: primaryColor,
        ),
        headlineLarge: GoogleFonts.montserratAlternates(
          fontWeight: FontWeight.w800,
          fontSize: 32,
          letterSpacing: -0.6,
          color: onSurfaceColor,
        ),
        headlineMedium: GoogleFonts.montserratAlternates(
          fontWeight: FontWeight.w700,
          fontSize: 26,
          letterSpacing: -0.4,
          color: onSurfaceColor,
        ),
        headlineSmall: GoogleFonts.montserratAlternates(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          letterSpacing: -0.3,
          color: onSurfaceColor,
        ),
        titleLarge: GoogleFonts.montserratAlternates(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: -0.3,
          color: onSurfaceColor,
        ),
        titleMedium: GoogleFonts.quicksand(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: onSurfaceColor,
        ),
        bodyLarge: GoogleFonts.quicksand(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: onSurfaceColor,
        ),
        bodyMedium: GoogleFonts.quicksand(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: onSurfaceColor,
        ),
        bodySmall: GoogleFonts.quicksand(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          color: secondaryColor,
        ),
        labelLarge: GoogleFonts.quicksand(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: 0.14,
          color: secondaryColor,
        ),
        labelSmall: GoogleFonts.quicksand(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          letterSpacing: 0.36,
          color: secondaryColor,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: secondaryContainer, width: 1.5),
        ),
        shadowColor: primaryColor.withValues(alpha: 0.05),
        margin: const EdgeInsets.all(16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: primaryColor.withValues(alpha: 0.2),
          textStyle: GoogleFonts.quicksand(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryContainer,
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: primaryColor,
        size: 26,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: onSurfaceColor),
        titleTextStyle: GoogleFonts.montserratAlternates(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: primaryColor,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    // Deep Dark Warm Palette from Prototype
    const Color primaryColor = Color(0xFFFFB1C9); 
    const Color onPrimary = Color(0xFF521E33);
    const Color primaryContainer = Color(0xFFC37C93);
    const Color onPrimaryContainer = Color(0xFF38081E);

    const Color secondaryColor = Color(0xFFE4BDC6);
    const Color onSecondary = Color(0xFF422931);
    const Color secondaryContainer = Color(0xFF342329);

    const Color tertiaryColor = Color(0xFFF3B997);
    const Color backgroundColor = Color(0xFF130E10);
    const Color surfaceColor = Color(0xFF1B1417);
    const Color surfaceContainerColor = Color(0xFF241A1E);
    const Color onSurfaceColor = Color(0xFFF3DFE2);
    const Color onSurfaceVariantColor = Color(0xFFD6C1C5);
    const Color errorColor = Color(0xFFFFB4AB);
    const Color outlineColor = Color(0xFF4D383F);

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: primaryColor,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondaryColor,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        tertiary: tertiaryColor,
        surface: surfaceColor,
        surfaceContainer: surfaceContainerColor,
        onSurface: onSurfaceColor,
        onSurfaceVariant: onSurfaceVariantColor,
        error: errorColor,
        onError: Color(0xFF690005),
        outline: outlineColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.quicksandTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.montserratAlternates(
          fontWeight: FontWeight.w800,
          fontSize: 40,
          letterSpacing: -0.8,
          color: primaryColor,
        ),
        headlineLarge: GoogleFonts.montserratAlternates(
          fontWeight: FontWeight.w800,
          fontSize: 32,
          letterSpacing: -0.6,
          color: onSurfaceColor,
        ),
        headlineMedium: GoogleFonts.montserratAlternates(
          fontWeight: FontWeight.w700,
          fontSize: 26,
          letterSpacing: -0.4,
          color: onSurfaceColor,
        ),
        headlineSmall: GoogleFonts.montserratAlternates(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          letterSpacing: -0.3,
          color: onSurfaceColor,
        ),
        titleLarge: GoogleFonts.montserratAlternates(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: -0.3,
          color: onSurfaceColor,
        ),
        titleMedium: GoogleFonts.quicksand(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: onSurfaceColor,
        ),
        bodyLarge: GoogleFonts.quicksand(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: onSurfaceColor,
        ),
        bodyMedium: GoogleFonts.quicksand(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: onSurfaceColor,
        ),
        bodySmall: GoogleFonts.quicksand(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          color: onSurfaceVariantColor,
        ),
        labelLarge: GoogleFonts.quicksand(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: 0.14,
          color: secondaryColor,
        ),
        labelSmall: GoogleFonts.quicksand(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          letterSpacing: 0.36,
          color: secondaryColor,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: outlineColor, width: 0.5),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.3),
        margin: const EdgeInsets.all(16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: primaryColor.withValues(alpha: 0.1),
          textStyle: GoogleFonts.quicksand(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryContainer,
          foregroundColor: onSurfaceColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: primaryColor,
        size: 26,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: onSurfaceColor),
        titleTextStyle: GoogleFonts.montserratAlternates(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: primaryColor,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
