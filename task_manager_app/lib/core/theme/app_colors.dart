import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryVariant = Color(0xFF4338CA); // Indigo 700
  static const Color primaryLight = Color(0xFFEEF2FF); // Indigo 50
  static const Color secondary = Color(0xFF0EA5E9); // Sky 500
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Neutral Colors Light
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color textMutedLight = Color(0xFF94A3B8); // Slate 400

  // Neutral Colors Dark
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color cardDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155); // Slate 700
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color textMutedDark = Color(0xFF64748B); // Slate 500

  // Semantic Status Colors
  static const Color todoBg = Color(0xFFFEF3C7); // Amber 100
  static const Color todoText = Color(0xFFD97706); // Amber 600
  static const Color todoBorder = Color(0xFFFDE68A);

  static const Color inProgressBg = Color(0xFFE0E7FF); // Indigo 100
  static const Color inProgressText = Color(0xFF4F46E5); // Indigo 600
  static const Color inProgressBorder = Color(0xFFC7D2FE);

  static const Color doneBg = Color(0xFFDCFCE7); // Emerald 100
  static const Color doneText = Color(0xFF16A34A); // Emerald 600
  static const Color doneBorder = Color(0xFFBBF7D0);

  // Functional
  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0xFFFEE2E2);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  static ColorScheme get lightColorScheme => const ColorScheme.light(
    primary: primary,
    onPrimary: onPrimary,
    secondary: secondary,
    surface: surfaceLight,
    error: error,
  );

  static ColorScheme get darkColorScheme => const ColorScheme.dark(
    primary: primary,
    onPrimary: onPrimary,
    secondary: secondary,
    surface: surfaceDark,
    error: error,
  );
}
