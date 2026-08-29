import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/theme_service.dart';

enum GlassButtonVariant {
  /// Deep Teal (#05624D) background with white text (Primary brand anchor)
  primary,

  /// Accent Lime (#DDF28A) background with Dark Neutral (#17201E) text (Primary CTA highlight)
  accent,

  /// Clean light surface with Deep Teal border and text (Secondary action)
  secondary,

  /// Minimal transparent touch target with Deep Teal text
  ghost,

  /// Luminous crimson red for dangerous or cancellation actions
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
    this.height = 52,
    this.width,
    this.borderRadius = 26,
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
        baseColor = widget.color ?? AppColors.deepTeal;
        contentColor = widget.textColor ?? Colors.white;
        gradientColors = [
          _isPressed ? AppColors.primaryDark : AppColors.deepTeal,
          _isPressed ? AppColors.primaryDark : AppColors.primaryLight,
        ];
        borderColor = AppColors.primaryLight.withValues(alpha: 0.6);
        glowColor = AppColors.deepTeal;
        break;

      case GlassButtonVariant.accent:
        baseColor = widget.color ?? AppColors.accentLime;
        contentColor = widget.textColor ?? AppColors.neutralDark;
        gradientColors = [
          _isPressed ? AppColors.accentLight : AppColors.accentLime,
          _isPressed ? AppColors.accentLime : const Color(0xFFD4EB78),
        ];
        borderColor = AppColors.accentLight;
        glowColor = AppColors.accentLime;
        break;

      case GlassButtonVariant.secondary:
        baseColor = isDark ? AppColors.darkCard : AppColors.white;
        contentColor = widget.textColor ?? (isDark ? AppColors.accentLime : AppColors.deepTeal);
        gradientColors = [
          baseColor.withValues(alpha: isDark ? 0.60 : 0.95),
          baseColor.withValues(alpha: isDark ? 0.40 : 0.85),
        ];
        borderColor = isDark ? AppColors.deepTeal.withValues(alpha: 0.5) : AppColors.deepTeal.withValues(alpha: 0.35);
        glowColor = Colors.transparent;
        break;

      case GlassButtonVariant.ghost:
        baseColor = Colors.transparent;
        contentColor = widget.textColor ?? (isDark ? AppColors.accentLime : AppColors.deepTeal);
        gradientColors = [Colors.transparent, Colors.transparent];
        borderColor = Colors.transparent;
        glowColor = Colors.transparent;
        break;

      case GlassButtonVariant.destructive:
        baseColor = widget.color ?? AppColors.error;
        contentColor = widget.textColor ?? Colors.white;
        gradientColors = [
          baseColor.withValues(alpha: 0.95),
          baseColor.withValues(alpha: 0.80),
        ];
        borderColor = AppColors.error.withValues(alpha: 0.5);
        glowColor = AppColors.error;
        break;
    }

    return AnimatedScale(
      scale: _isPressed && isEnabled ? 0.98 : 1.0,
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
                    color: glowColor.withValues(alpha: isDark ? 0.25 : 0.16),
                    blurRadius: 14,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
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
                              Colors.grey.withValues(alpha: 0.2),
                              Colors.grey.withValues(alpha: 0.1),
                            ],
                    ),
                    border: Border.all(
                      color: isEnabled ? borderColor : Colors.transparent,
                      width: 1.1,
                    ),
                  ),
                  child: Center(
                    child: widget.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: contentColor,
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
                                  size: 18,
                                  color: isEnabled ? contentColor : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                widget.text,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: isEnabled ? contentColor : Colors.grey,
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
