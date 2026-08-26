import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Neon Crystal Accents ──────────────────────────────────────────────────
  static const Color primary = Color(0xFF00E676); // Neon Emerald
  static const Color primaryDark = Color(0xFF00B248);
  static const Color primaryLight = Color(0xFFE8FFF0);

  static const Color cyan = Color(0xFF00E5FF); // Electric Cyan
  static const Color purple = Color(0xFF8B5CF6); // Neon Violet
  static const Color amber = Color(0xFFFFB300); // Electric Amber
  static const Color rose = Color(0xFFF43F5E); // Neon Rose

  // ── Cosmic Glass Surfaces ─────────────────────────────────────────────────
  static const Color glassDarkBg = Color(0xFF0B132B);
  static const Color glassSurface = Color(0x1FFFFFFF); // 12% White
  static const Color glassSurfaceMedium = Color(0x33FFFFFF); // 20% White
  static const Color glassBorder = Color(0x40FFFFFF); // 25% White
  static const Color glassBorderGlow = Color(0x80FFFFFF); // 50% White

  // ── Typography ────────────────────────────────────────────────────────────
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color textMuted = Color(0xFF64748B); // Slate 500

  // ── Functional ────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF00E676);
}