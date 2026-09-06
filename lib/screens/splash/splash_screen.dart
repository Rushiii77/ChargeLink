import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';
import '../../widgets/glass/glass_background.dart';
import '../../widgets/glass/glass_container.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final AuthService _authService = AuthService();
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _controller.forward();

    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    try {
      final user = _authService.currentUser;
      if (user != null) {
        final role = await _authService.getUserRole(user.uid);
        if (!mounted) return;

        if (role == 'owner') {
          Navigator.pushReplacementNamed(context, '/owner-home');
        } else if (role == 'customer') {
          Navigator.pushReplacementNamed(context, '/customer-home');
        } else {
          Navigator.pushReplacementNamed(context, '/role-selection');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDark(context);

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _animation,
              child: ScaleTransition(
                scale: _animation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Floating Crystal Logo Card
                    GlassContainer(
                      tier: GlassTier.primary,
                      width: 140,
                      height: 140,
                      borderRadius: BorderRadius.circular(36),
                      glowColor: AppColors.accentLime,
                      glowSpread: 2,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? AppColors.deepTeal : AppColors.accentLime,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.deepTeal.withValues(alpha: 0.3),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.ev_station_rounded,
                            size: 48,
                            color: isDark ? AppColors.accentLime : AppColors.deepTeal,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    Text(
                      "ChargeLink",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: isDark ? AppColors.darkText : AppColors.neutralDark,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.deepTeal.withValues(alpha: 0.35)
                            : AppColors.accentLime.withValues(alpha: 0.40),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppColors.accentLime.withValues(alpha: 0.4) : AppColors.deepTeal.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        "Smart EV Charging & Mobility Network",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.accentLime : AppColors.primaryDark,
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),

                    // Crystal Spinner
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? AppColors.accentLime : AppColors.deepTeal,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      "Connecting to smart charging grid...",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
