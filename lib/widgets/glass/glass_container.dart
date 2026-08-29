import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/theme_service.dart';

enum GlassTier {
  /// Navigation bars, major bottom sheets, checkout modals (strongest blur & presence)
  primary,

  /// Station cards, dashboard summary widgets, booking tiles
  secondary,

  /// Action pills, input containers, badges, chips
  tertiary,
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final GlassTier tier;
  final double? blur;
  final double? opacity;
  final Color? color;
  final Color? borderColor;
  final double? borderWidth;
  final Color? glowColor;
  final double glowSpread;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.tier = GlassTier.secondary,
    this.blur,
    this.opacity,
    this.color,
    this.borderColor,
    this.borderWidth,
    this.glowColor,
    this.glowSpread = 0.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(22);
    final isDark = ThemeService.isDark(context);

    // Tier-calibrated metrics
    final double defaultBlur;
    final double defaultDarkOpacity;
    final double defaultLightOpacity;
    final double defaultBorderWidth;

    switch (tier) {
      case GlassTier.primary:
        defaultBlur = 24.0;
        defaultDarkOpacity = 0.40;
        defaultLightOpacity = 0.88;
        defaultBorderWidth = 1.2;
        break;
      case GlassTier.secondary:
        defaultBlur = 16.0;
        defaultDarkOpacity = 0.18;
        defaultLightOpacity = 0.72;
        defaultBorderWidth = 1.0;
        break;
      case GlassTier.tertiary:
        defaultBlur = 10.0;
        defaultDarkOpacity = 0.08;
        defaultLightOpacity = 0.45;
        defaultBorderWidth = 0.8;
        break;
    }

    final effectiveBlur = blur ?? defaultBlur;
    final effectiveOpacity = opacity ?? (isDark ? defaultDarkOpacity : defaultLightOpacity);
    final effectiveColor = color ?? (isDark ? const Color(0xFF0F172A) : Colors.white);
    final effectiveBorderWidth = borderWidth ?? defaultBorderWidth;
    final effectiveBorderColor = borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: tier == GlassTier.primary ? 0.25 : 0.16)
            : Colors.white.withValues(alpha: tier == GlassTier.primary ? 0.90 : 0.75));

    return RepaintBoundary(
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: effectiveRadius,
          boxShadow: [
            if (glowColor != null)
              BoxShadow(
                color: glowColor!.withValues(alpha: isDark ? 0.28 : 0.20),
                blurRadius: 18 + glowSpread,
                spreadRadius: glowSpread,
                offset: const Offset(0, 4),
              )
            else if (tier == GlassTier.primary)
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.35)
                    : const Color(0xFF64748B).withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              )
            else if (tier == GlassTier.secondary)
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.18)
                    : const Color(0xFF64748B).withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: effectiveRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: effectiveRadius,
                splashColor: const Color(0xFF00E676).withValues(alpha: 0.12),
                highlightColor: const Color(0xFF00E676).withValues(alpha: 0.05),
                child: Container(
                  padding: padding,
                  decoration: BoxDecoration(
                    borderRadius: effectiveRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        effectiveColor.withValues(
                            alpha: (effectiveOpacity + 0.08).clamp(0.0, 1.0)),
                        effectiveColor.withValues(
                            alpha: effectiveOpacity.clamp(0.0, 1.0)),
                      ],
                    ),
                    border: Border.all(
                      color: effectiveBorderColor,
                      width: effectiveBorderWidth,
                    ),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
