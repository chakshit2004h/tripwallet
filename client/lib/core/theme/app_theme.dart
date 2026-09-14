import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.ink,
      primaryColor: AppColors.coral,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.coral,
        surface: AppColors.card,
        error: Colors.redAccent,
        onPrimary: AppColors.cream,
        onSurface: AppColors.cream,
      ),
      cardColor: AppColors.card,
      dividerColor: AppColors.line,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleMedium,
        iconTheme: const IconThemeData(color: AppColors.cream),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.coral,
          foregroundColor: AppColors.cream,
          elevation: 0,
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size.fromHeight(44),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.cream,
          side: const BorderSide(color: AppColors.line, width: 1.4),
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size.fromHeight(44),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paper,
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.inkSoft),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line, width: 1.4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line, width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.coral, width: 1.4),
        ),
      ),
    );
  }
}
