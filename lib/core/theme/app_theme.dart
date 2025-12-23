import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color greenPrimary = Color(0xFF58CC02);
  static const Color greenDark = Color(0xFF46A302);
  static const Color blueSky = Color(0xFFCEEAFF);
  static const Color orangeFire = Color(0xFFFF9600);
  static const Color yellowGold = Color(0xFFFFD900);
  static const Color textDark = Color(0xFF4B4B4B);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,

      colorScheme: ColorScheme.fromSeed(
        seedColor: greenPrimary,
        primary: greenPrimary,
        surface: Colors.white,
        onSurface: textDark,
      ),

      textTheme: GoogleFonts.nunitoTextTheme(
        const TextTheme(
          headlineMedium: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
          titleLarge: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          bodyLarge: TextStyle(
            color: textDark,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.nunito(
          color: blueSky,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(color: Colors.grey),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: greenPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
