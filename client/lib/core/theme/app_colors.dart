import 'package:flutter/material.dart';

/// Design tokens derived directly from the official TripWallet prototype specification:
/// --ink:#0F1B2C; --ink-2:#16273E; --cream:#F4EFE4; --cream-soft:#C9C2AE;
/// --coral:#FF6B4A; --coral-dark:#D4502F; --coral-tint:#FCE9E3;
/// --gold:#F2B705;
/// --card:#FFFFFF; --paper:#FAF8F4; --line:#E7E2D5;
/// --ink-text:#10221C; --ink-soft:#63706A;
class AppColors {
  // Canvas & Surfaces
  static const Color ink = Color(0xFF0F1B2C); // Structural chrome, primary buttons
  static const Color inkSecondary = Color(0xFF16273E);
  static const Color card = Color(0xFFFFFFFF); // Screen canvas & white cards
  static const Color paper = Color(0xFFFAF8F4); // Surface card background
  static const Color line = Color(0xFFE7E2D5); // Borders & dividers
  static const Color lineHeavy = Color(0xFFD4CEC0);

  // Accents & Signals
  static const Color coral = Color(0xFFFF6B4A); // Action, scan, money-in-motion
  static const Color coralDark = Color(0xFFD4502F);
  static const Color coralTint = Color(0xFFFCE9E3); // Soft blush tint
  static const Color green = Color(0xFF1D9E75); // Settled green & positive balances
  static const Color greenTint = Color(0xFFE1F5EE);
  static const Color gold = Color(0xFFF2B705);
  static const Color yellow = Color(0xFFF2B705);
  static const Color amber = Color(0xFFF2B705);
  static const Color teal = Color(0xFF29B6F6);

  // Typography
  static const Color inkText = Color(0xFF10221C); // Primary text in light theme
  static const Color inkSoft = Color(0xFF63706A); // Subtitle / secondary text
  static const Color muted = Color(0xFF63706A);
  static const Color cream = Color(0xFFF4EFE4); // Text in dark splash
  static const Color creamSoft = Color(0xFFC9C2AE);
}
