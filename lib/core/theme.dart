import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Custom Color Palette (Synchronized with Wave Header)
  static const Color primary = Color(0xFF1656B9); // Deep Blue from Clipper
  static const Color primaryDark = Color(0xFF0F3D83); 
  static const Color background = Color(0xFFF0F5F9); 
  static const Color surface = Color(0xFF9CB7C7);
  static const Color accent = Color(0xFF4ACFC0); // Bright Teal from Clipper
  static const Color textPrimary = Color(0xFF1F2D33);
  static const Color textSecondary = Color(0xFF5A7381);
  
  // Custom Gradient Colors for Wave Header
  static const Color gradientDark = primary;
  static const Color gradientLight = accent;
  
  // Background Colors for Quick Actions
  static const Color actionBlueBg = Color(0xFFE5EDFC);
  static const Color actionBlueIcon = Color(0xFF2C6ECB);
  
  static const Color actionGreenBg = Color(0xFFE4F6F1);
  static const Color actionGreenIcon = Color(0xFF1A936F);
  
  static const Color actionOrangeBg = Color(0xFFFDF0E1);
  static const Color actionOrangeIcon = Color(0xFFD47C1F);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primary,
      fontFamily: GoogleFonts.inter().fontFamily,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: surface,
        surfaceBright: background,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        bodyLarge: const TextStyle(color: textPrimary),
        bodyMedium: const TextStyle(color: textPrimary),
        displayLarge: GoogleFonts.poppins(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.poppins(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: GoogleFonts.poppins(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: GoogleFonts.poppins(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.poppins(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: GoogleFonts.poppins(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.poppins(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: GoogleFonts.poppins(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: GoogleFonts.poppins(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        iconTheme: const IconThemeData(color: primary),
        titleTextStyle: GoogleFonts.poppins(
          color: primary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
    );
  }
}
