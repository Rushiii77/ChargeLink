import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';
import '../../widgets/glass/glass_background.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_container.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? selectedRole;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _handleContinue() async {
    if (selectedRole == null) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        await _authService.updateUserRole(
          uid: currentUser.uid,
          role: selectedRole!,
        );
      }

      if (!mounted) return;

      if (selectedRole == 'owner') {
        Navigator.pushReplacementNamed(context, '/owner-home');
      } else {
        Navigator.pushReplacementNamed(context, '/customer-home');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save role. Please try again.'),
            backgroundColor: Colors.redAccent.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDark(context);

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Step Pill
                GlassContainer(
                  tier: GlassTier.tertiary,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  borderRadius: BorderRadius.circular(20),
                  child: Text(
                    "STEP 2 OF 2",
                    style: TextStyle(
                      color: isDark ? const Color(0xFF00E676) : const Color(0xFF00A040),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  "Choose Your Role",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Select how you plan to use ChargeLink. You can switch or add roles anytime in settings.",
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 32),

                // Role Card 1: EV Driver
                _buildRoleOption(
                  roleValue: 'customer',
                  title: 'EV Driver / Customer',
                  description: 'Discover nearby chargers, check live occupancy, and reserve charging slots seamlessly.',
                  icon: Icons.electric_car_rounded,
                  iconColor: const Color(0xFF00E676),
                  isDark: isDark,
                ),

                const SizedBox(height: 16),

                // Role Card 2: Station Host
                _buildRoleOption(
                  roleValue: 'owner',
                  title: 'Station Host / Owner',
                  description: 'List your private or commercial charging station, manage pricing, and earn revenue.',
                  icon: Icons.ev_station_rounded,
                  iconColor: const Color(0xFF00E5FF),
                  isDark: isDark,
                ),

                const Spacer(),

                // Continue CTA Button
                GlassButton(
                  text: selectedRole != null ? "GET STARTED" : "SELECT A ROLE",
                  isLoading: _isLoading,
                  icon: Icons.arrow_forward_rounded,
                  onPressed: selectedRole != null ? _handleContinue : null,
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required String roleValue,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    final isSelected = selectedRole == roleValue;

    return GlassContainer(
      tier: GlassTier.secondary,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      borderColor: isSelected
          ? const Color(0xFF00E676)
          : (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.08)),
      borderWidth: isSelected ? 2.0 : 1.0,
      glowColor: isSelected ? const Color(0xFF00E676) : null,
      glowSpread: isSelected ? 2 : 0,
      onTap: () => setState(() => selectedRole = roleValue),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.18 : 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? iconColor : iconColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white.withValues(alpha: 0.65) : const Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? const Color(0xFF00E676) : Colors.transparent,
              border: Border.all(
                color: isSelected ? const Color(0xFF00E676) : (isDark ? Colors.white38 : Colors.black26),
                width: 2,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 14, color: Color(0xFF0B132B))
                : null,
          ),
        ],
      ),
    );
  }
}