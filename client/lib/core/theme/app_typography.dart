import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle get display => TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.1,
    color: AppColors.inkText,
  );

  static TextStyle get titleLarge => TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.inkText,
  );

  static TextStyle get titleMedium => TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.inkText,
  );

  static TextStyle get bodyLarge => TextStyle(
    fontFamily: 'Inter',
    fontSize: 14.5,
    fontWeight: FontWeight.w400,
    color: AppColors.inkSoft,
    height: 1.5,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.inkText,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.inkSoft,
  );

  static TextStyle get caption => TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.inkSoft,
  );

  static TextStyle get labelLarge => TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.inkText,
  );

  static TextStyle get button => TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
