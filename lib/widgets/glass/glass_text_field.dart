import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/theme_service.dart';

class GlassTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.validator,
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDark(context);

    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (_isFocused)
              BoxShadow(
                color: AppColors.deepTeal.withValues(alpha: isDark ? 0.35 : 0.18),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              onFieldSubmitted: widget.onFieldSubmitted,
              validator: widget.validator,
              style: TextStyle(
                color: isDark ? AppColors.darkText : AppColors.neutralDark,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark
                    ? AppColors.darkCard.withValues(alpha: _isFocused ? 0.75 : 0.50)
                    : AppColors.white.withValues(alpha: _isFocused ? 0.95 : 0.85),
                labelText: widget.labelText,
                labelStyle: TextStyle(
                  color: _isFocused
                      ? (isDark ? AppColors.accentLime : AppColors.deepTeal)
                      : (isDark ? AppColors.darkTextSecondary : AppColors.neutral),
                  fontSize: 14,
                  fontWeight: _isFocused ? FontWeight.bold : FontWeight.w500,
                ),
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: isDark ? AppColors.neutral : AppColors.neutral.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: _isFocused
                            ? (isDark ? AppColors.accentLime : AppColors.deepTeal)
                            : (isDark ? AppColors.darkTextSecondary : AppColors.neutral),
                        size: 20,
                      )
                    : null,
                suffixIcon: widget.suffixIcon,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.deepTeal.withValues(alpha: 0.3)
                        : AppColors.neutral.withValues(alpha: 0.2),
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.accentLime : AppColors.deepTeal,
                    width: 1.8,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 1.2,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 1.8,
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
