import 'package:flutter/material.dart';
import 'package:nutrition_app/core/theme/design_tokens.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: DesignTokens.primaryGreen,
        brightness: Brightness.light,
        surface: DesignTokens.surfaceLight,
      ),
      scaffoldBackgroundColor: DesignTokens.backgroundLight,
      fontFamily: DesignTokens.fontFamily,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: DesignTokens.surfaceLight,
        foregroundColor: DesignTokens.textPrimary,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: DesignTokens.textPrimary,
        ),
      ),
      // cardTheme: CardTheme(
      //   elevation: 0,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
      //     side: BorderSide(color: Colors.grey.shade200),
      //   ),
      //   color: DesignTokens.surfaceLight,
      // ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceLG,
            vertical: DesignTokens.spaceMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignTokens.surfaceLight,
        contentPadding: const EdgeInsets.all(DesignTokens.spaceMD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
          borderSide: const BorderSide(color: DesignTokens.primaryGreen, width: 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: DesignTokens.primaryGreen,
        brightness: Brightness.dark,
        surface: DesignTokens.surfaceDark,
      ),
      scaffoldBackgroundColor: DesignTokens.backgroundDark,
      fontFamily: DesignTokens.fontFamily,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: DesignTokens.surfaceDark,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      // cardTheme: CardTheme(
      //   elevation: 0,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
      //     side: BorderSide(color: Colors.grey.shade800),
      //   ),
      //   color: DesignTokens.surfaceDark,
      // ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceLG,
            vertical: DesignTokens.spaceMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}