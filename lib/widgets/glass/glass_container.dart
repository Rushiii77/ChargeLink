import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/theme_service.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blur;
  final double? opacity;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
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
    this.blur = 16.0,
    this.opacity,
    this.color,
    this.borderColor,
    this.borderWidth = 1.2,
    this.glowColor,
    this.glowSpread = 0.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(20);
    final isDark = ThemeService.isDark(context);

    final effectiveColor = color ?? (isDark ? Colors.white : Colors.white);
    final effectiveOpacity = opacity ?? (isDark ? 0.12 : 0.75);
    final effectiveBorderColor = borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.22)
            : Colors.white.withValues(alpha: 0.8));

    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: [
          if (glowColor != null)
            BoxShadow(
              color: glowColor!.withValues(alpha: isDark ? 0.25 : 0.2),
              blurRadius: 20 + glowSpread,
              spreadRadius: glowSpread,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.18)
                  : const Color(0xFF64748B).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
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
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
