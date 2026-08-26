import 'package:flutter/material.dart';
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF0B132B), // Deep Cosmic Midnight
                  Color(0xFF1C2541), // Deep Slate Indigo
                  Color(0xFF0B1E1A), // Dark Emerald Ambient
                ]
              : const [
                  Color(0xFFF8FAFC), // Icy Sky White
                  Color(0xFFE2E8F0), // Soft Frosted Slate
                  Color(0xFFE0F2FE), // Soft Cyan Ambient
                ],
        ),
      ),
      child: Stack(
        children: [
          if (showOrbs) ...[
            // Top-Right Glowing Emerald Aurora Orb
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: size.width * 0.75,
                height: size.width * 0.75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00E676).withValues(alpha: isDark ? 0.35 : 0.2),
                      const Color(0xFF00E676).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Mid-Left Cyan Neon Orb
            Positioned(
              top: size.height * 0.35,
              left: -80,
              child: Container(
                width: size.width * 0.7,
                height: size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00E5FF).withValues(alpha: isDark ? 0.25 : 0.18),
                      const Color(0xFF00E5FF).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom-Right Violet Glow Orb
            Positioned(
              bottom: -40,
              right: -40,
              child: Container(
                width: size.width * 0.65,
                height: size.width * 0.65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.25 : 0.15),
                      const Color(0xFF8B5CF6).withValues(alpha: 0.0),
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
