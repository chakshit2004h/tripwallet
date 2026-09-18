import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle get display => GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02,
        color: AppColors.cream,
      );

  static TextStyle get titleLarge => GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.01,
        color: AppColors.cream,
      );

  static TextStyle get titleMedium => GoogleFonts.spaceGrotesk(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.cream,
      );

  static TextStyle get bodyLarge => GoogleFonts.spaceGrotesk(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.creamSoft,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.spaceGrotesk(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.creamSoft,
      );

  static TextStyle get bodySmall => GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.creamSoft,
      );

  static TextStyle get caption => GoogleFonts.spaceGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.inkSoft,
      );

  static TextStyle get button => GoogleFonts.spaceGrotesk(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.cream,
      );
}
