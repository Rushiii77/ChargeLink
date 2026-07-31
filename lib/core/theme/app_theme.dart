import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    colorSchemeSeed: AppColors.primary,

    scaffoldBackgroundColor: AppColors.background,

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}