import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // ── Light Theme (Off-White Canvas + Deep Teal Anchors + Lime Accents) ──────
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.deepTeal,
      onPrimary: Colors.white,
      secondary: AppColors.accentLime,
      onSecondary: AppColors.neutralDark,
      surface: AppColors.white,
      onSurface: AppColors.neutralDark,
      error: AppColors.error,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.lightBg,
    fontFamily: 'Roboto',

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.neutralDark,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.deepTeal,
      contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
  );

  // ── Dark Theme (Deep Charcoal Teal Canvas + Deep Teal + Lime Accents) ───────
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.deepTeal,
      onPrimary: Colors.white,
      secondary: AppColors.accentLime,
      onSecondary: AppColors.neutralDark,
      surface: AppColors.darkCard,
      onSurface: AppColors.darkText,
      error: AppColors.error,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.darkBg,
    fontFamily: 'Roboto',

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.darkCard,
      contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
  );
}