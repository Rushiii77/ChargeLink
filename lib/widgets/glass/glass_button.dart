import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/theme_service.dart';

enum GlassButtonVariant {
  /// Luminous primary action with glowing emerald gradient
  primary,

  /// Frosted crystal secondary surface with crisp translucent border
  secondary,

  /// Minimal transparent touch target with soft hover/press tint
  ghost,

  /// Luminous rose crimson for dangerous or cancellation actions
  destructive,
}

class GlassButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final GlassButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final double height;
  final double? width;
  final double borderRadius;

  const GlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = GlassButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.color,
    this.textColor,
    this.height = 54,
    this.width,
    this.borderRadius = 28,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDark(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    Color baseColor;
    Color contentColor;
    List<Color> gradientColors;
    Color borderColor;
    Color glowColor;

    switch (widget.variant) {
      case GlassButtonVariant.primary:
        baseColor = widget.color ?? const Color(0xFF00E676);
        contentColor = widget.textColor ?? Colors.white;
        gradientColors = [
          baseColor.withValues(alpha: 0.95),
          baseColor.withValues(alpha: 0.75),
        ];
        borderColor = Colors.white.withValues(alpha: 0.4);
        glowColor = baseColor;
        break;

      case GlassButtonVariant.secondary:
        baseColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        contentColor = widget.textColor ?? (isDark ? Colors.white : const Color(0xFF0F172A));
        gradientColors = [
          baseColor.withValues(alpha: isDark ? 0.35 : 0.9),
          baseColor.withValues(alpha: isDark ? 0.20 : 0.7),
        ];
        borderColor = isDark ? Colors.white.withValues(alpha: 0.22) : Colors.black.withValues(alpha: 0.12);
        glowColor = Colors.transparent;
        break;

      case GlassButtonVariant.ghost:
        baseColor = Colors.transparent;
        contentColor = widget.textColor ?? (isDark ? Colors.white70 : const Color(0xFF475569));
        gradientColors = [Colors.transparent, Colors.transparent];
        borderColor = Colors.transparent;
        glowColor = Colors.transparent;
        break;

      case GlassButtonVariant.destructive:
        baseColor = widget.color ?? const Color(0xFFF43F5E);
        contentColor = widget.textColor ?? Colors.white;
        gradientColors = [
          baseColor.withValues(alpha: 0.95),
          baseColor.withValues(alpha: 0.80),
        ];
        borderColor = Colors.white.withValues(alpha: 0.35);
        glowColor = baseColor;
        break;
    }

    return AnimatedScale(
      scale: _isPressed && isEnabled ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      child: Container(
        width: widget.width ?? double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: isEnabled && glowColor != Colors.transparent
              ? [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.30),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isEnabled ? widget.onPressed : null,
                onHighlightChanged: (val) => setState(() => _isPressed = val),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isEnabled
                          ? gradientColors
                          : [
                              Colors.white.withValues(alpha: 0.08),
                              Colors.white.withValues(alpha: 0.04),
                            ],
                    ),
                    border: Border.all(
                      color: isEnabled ? borderColor : Colors.white.withValues(alpha: 0.08),
                      width: 1.1,
                    ),
                  ),
                  child: Center(
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.2,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(
                                  widget.icon,
                                  size: 19,
                                  color: isEnabled ? contentColor : Colors.white38,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                widget.text,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: isEnabled ? contentColor : Colors.white38,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
