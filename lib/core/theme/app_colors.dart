import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Neon Crystal Accents (Vibrant in both modes) ──────────────────────────
  static const Color primary = Color(0xFF00E676); // Neon Emerald
  static const Color primaryDark = Color(0xFF00B248);
  static const Color primaryLight = Color(0xFFE8FFF0);

  static const Color cyan = Color(0xFF00E5FF); // Electric Cyan
  static const Color purple = Color(0xFF8B5CF6); // Neon Violet
  static const Color amber = Color(0xFFFFB300); // Electric Amber
  static const Color rose = Color(0xFFF43F5E); // Neon Rose

  // ── Dark Mode Cosmic Surfaces ─────────────────────────────────────────────
  static const Color darkBg = Color(0xFF0B132B);
  static const Color darkCard = Color(0xFF141E3C);
  static const Color darkSurface = Color(0x1FFFFFFF);
  static const Color darkText = Colors.white;
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // ── Light Mode Icy Daylight Surfaces ──────────────────────────────────────
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightCard = Colors.white;
  static const Color lightSurface = Color(0xD9FFFFFF);
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // ── Functional ────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF00E676);

  // ── Adaptive Helpers ──────────────────────────────────────────────────────
  static Color background(bool isDark) => isDark ? darkBg : lightBg;
  static Color cardBg(bool isDark) => isDark ? darkCard : lightCard;
  static Color text(bool isDark) => isDark ? darkText : lightText;
  static Color textSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
}