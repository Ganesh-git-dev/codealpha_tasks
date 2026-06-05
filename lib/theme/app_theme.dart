import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryDark = Color(0xFF1A1A2E);
  static const Color primaryMid = Color(0xFF16213E);
  static const Color accent1 = Color(0xFF0F3460);
  static const Color accent2 = Color(0xFF533483);
  static const Color gradientStart = Color(0xFF667eea);
  static const Color gradientEnd = Color(0xFF764ba2);
  static const Color cardBg = Color(0xFF1E2A4A);
  static const Color surfaceDark = Color(0xFF0D1B2A);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFEF5350);
  static const Color fitness = Color(0xFF00E676);
  static const Color language = Color(0xFF40C4FF);
  static const Color flashcard = Color(0xFFFFD740);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: surfaceDark,
      primaryColor: primaryDark,
      colorScheme: ColorScheme.dark(
        primary: gradientStart,
        secondary: accent2,
        surface: cardBg,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: gradientStart,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: gradientStart, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: primaryDark,
        selectedItemColor: gradientStart,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get fitnessGradient => const LinearGradient(
    colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get languageGradient => const LinearGradient(
    colors: [Color(0xFFAA076B), Color(0xFF61045F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get flashcardGradient => const LinearGradient(
    colors: [Color(0xFFF2994A), Color(0xFFF2C94C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get cardGradient => const LinearGradient(
    colors: [Color(0xFF2C3E50), Color(0xFF1A1A2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
