import 'package:flutter/material.dart';

/// Centralized Design System Color Tokens
/// 60% Light Background / Neutral
/// 30% Deep Teal Structural Elements
/// 10% Accent Lime Highlights
class AppColors {
  AppColors._();

  // ── Primary Deep Teal Palette (30% Structure & Anchors) ────────────────────
  static const Color deepTeal = Color(0xFF05624D);      // Primary Brand Color
  static const Color primary = deepTeal;
  static const Color primaryDark = Color(0xFF034A3A);  // Hover/Pressed & Dark Sections
  static const Color primaryLight = Color(0xFF0A7A61); // Subtle Highlights & Borders

  // ── Accent Lime Palette (10% Special Accent Highlights) ────────────────────
  static const Color accentLime = Color(0xFFDDF28A);    // Primary CTA Highlights & Key Indicators
  static const Color accent = accentLime;
  static const Color accentLight = Color(0xFFEAF7B5);   // Soft Highlight Badges & Info Backgrounds

  // ── Neutral Dark & Typography (Core Text Hierarchy) ────────────────────────
  static const Color neutralDark = Color(0xFF17201E);   // Main Headings & Primary Text
  static const Color neutral = Color(0xFF5F6864);       // Secondary Text, Captions, Metadata
  static const Color neutralLight = Color(0xFFB8C2BD);  // Subtle Dividers & Outline Rings

  // ── Canvas & Surface Tokens (60% Foundation) ───────────────────────────────
  static const Color lightBg = Color(0xFFF5F7F3);       // Main Application Canvas
  static const Color white = Color(0xFFFFFFFF);         // Elevated Surfaces & Form Cards
  static const Color surface = white;

  // ── Dark Mode Deep Charcoal Teal Palette ───────────────────────────────────
  static const Color darkBg = Color(0xFF0E1715);        // Deep Charcoal Canvas
  static const Color darkCard = Color(0xFF172320);      // Elevated Dark Surface
  static const Color darkSurface = Color(0x1F05624D);   // Translucent Dark Teal Glass
  static const Color darkText = Color(0xFFF5F7F3);      // Light Crisp Text on Dark
  static const Color darkTextSecondary = Color(0xFF9CA8A4); // Muted Dark Subtext

  // ── Semantic Feedback ──────────────────────────────────────────────────────
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF05624D);
  static const Color info = Color(0xFF0A7A61);

  // ── Adaptive Helpers ───────────────────────────────────────────────────────
  static Color background(bool isDark) => isDark ? darkBg : lightBg;
  static Color cardBg(bool isDark) => isDark ? darkCard : white;
  static Color text(bool isDark) => isDark ? darkText : neutralDark;
  static Color textSecondary(bool isDark) => isDark ? darkTextSecondary : neutral;
}