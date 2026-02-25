// lib/core/theme/app_theme.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AppColors {
  // Dark theme
  static const Color darkBackground = Color(0xFF0D0D0F);
  static const Color darkSurface = Color(0xFF1A1A1F);
  static const Color darkCard = Color(0xFF242429);
  static const Color darkBorder = Color(0xFF2E2E35);

  // Button colors - dark
  static const Color btnNumber = Color(0xFF1E1E24);
  static const Color btnOperator = Color(0xFF2A2A32);
  static const Color btnScientific = Color(0xFF161620);
  static const Color btnEquals = Color(0xFF4F7BFF);
  static const Color btnClear = Color(0xFF3D2020);
  static const Color btnClearText = Color(0xFFFF5252);

  // Light theme
  static const Color lightBackground = Color(0xFFF5F5F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFEEEEF0);
  static const Color lightBorder = Color(0xFFDDDDE0);

  // Button colors - light
  static const Color btnNumberLight = Color(0xFFFFFFFF);
  static const Color btnOperatorLight = Color(0xFFE8E8F0);
  static const Color btnScientificLight = Color(0xFFF0F0F8);
  static const Color btnClearLight = Color(0xFFFFE8E8);
  static const Color btnClearTextLight = Color(0xFFCC0000);

  // Shared
  static const Color accent = Color(0xFF4F7BFF);
  static const Color accentSecondary = Color(0xFF7B4FFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color textDark = Color(0xFF111111);
  static const Color textDarkSecondary = Color(0xFF666688);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFFF5252);
  static const Color equalsText = Color(0xFFFFFFFF);
  static const Color graphLine = Color(0xFF4F7BFF);
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.accentSecondary,
      surface: AppColors.darkSurface,
      background: AppColors.darkBackground,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    fontFamily: 'SF Pro Display',
    cardColor: AppColors.darkCard,
    dividerColor: AppColors.darkBorder,
    textTheme: _buildTextTheme(Colors.white),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      indicatorColor: AppColors.accent.withOpacity(0.2),
      labelTextStyle: MaterialStateProperty.all(
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkCard,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.accent,
      secondary: AppColors.accentSecondary,
      surface: AppColors.lightSurface,
      background: AppColors.lightBackground,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    fontFamily: 'SF Pro Display',
    cardColor: AppColors.lightCard,
    dividerColor: AppColors.lightBorder,
    textTheme: _buildTextTheme(AppColors.textDark),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.textDark,
      elevation: 0,
      centerTitle: true,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      indicatorColor: AppColors.accent.withOpacity(0.15),
      labelTextStyle: MaterialStateProperty.all(
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textDark,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  static TextTheme _buildTextTheme(Color baseColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 64,
        fontWeight: FontWeight.w300,
        color: baseColor,
        letterSpacing: -2,
      ),
      displayMedium: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w300,
        color: baseColor,
        letterSpacing: -1.5,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: -1,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: baseColor),
      bodyMedium: TextStyle(fontSize: 14, color: baseColor.withOpacity(0.7)),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.5,
      ),
    );
  }
}
