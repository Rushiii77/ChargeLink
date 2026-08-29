import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/theme_service.dart';

class GlassBackground extends StatelessWidget {
  final Widget child;
  final bool showOrbs;

  const GlassBackground({
    super.key,
    required this.child,
    this.showOrbs = true,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = ThemeService.isDark(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : AppColors.lightBg,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF0E1715), // Deep Charcoal
                  Color(0xFF14221F), // Dark Teal Atmosphere
                  Color(0xFF0B1614), // Deep Obsidian Teal
                ]
              : const [
                  Color(0xFFF5F7F3), // Off-White Canvas (60%)
                  Color(0xFFEDF2EA), // Soft Warm Neutral
                  Color(0xFFF2F6F0), // Subtle Green-Gray Wash
                ],
        ),
      ),
      child: Stack(
        children: [
          if (showOrbs) ...[
            // Top-Right Subtle Deep Teal Ambient Orb (Atmospheric)
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: size.width * 0.85,
                height: size.width * 0.85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.deepTeal.withValues(alpha: isDark ? 0.20 : 0.07),
                      AppColors.deepTeal.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Mid-Left Soft Accent Lime Light Glow (10% Accent Principle)
            Positioned(
              top: size.height * 0.40,
              left: -90,
              child: Container(
                width: size.width * 0.70,
                height: size.width * 0.70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentLime.withValues(alpha: isDark ? 0.12 : 0.08),
                      AppColors.accentLime.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom-Right Deep Teal Atmosphere
            Positioned(
              bottom: -60,
              right: -60,
              child: Container(
                width: size.width * 0.75,
                height: size.width * 0.75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryLight.withValues(alpha: isDark ? 0.15 : 0.05),
                      AppColors.primaryLight.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Foreground screen content
          child,
        ],
      ),
    );
  }
}
