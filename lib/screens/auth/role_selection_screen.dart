import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  borderRadius: BorderRadius.circular(20),
                  blur: 16,
                  opacity: 0.15,
                  child: const Text(
                    "STEP 2 OF 2",
                    style: TextStyle(
                      color: Color(0xFF00E676),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  "Choose Your Role",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Select how you plan to use ChargeLink. You can switch or add roles anytime in settings.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 36),

                // Role Option 1: EV Driver
                _buildRoleOption(
                  title: "EV Owner & Driver",
                  badge: "Recommended for Drivers",
                  description:
                      "Discover high-speed chargers, check live availability, AI match, and reserve slots seamlessly.",
                  icon: Icons.electric_car_rounded,
                  value: "customer",
                  accentColor: const Color(0xFF00E676),
                ),

                const SizedBox(height: 20),

                // Role Option 2: Station Host
                _buildRoleOption(
                  title: "Charging Station Host",
                  badge: "Monetize Your Charger",
                  description:
                      "List your private or commercial charger, manage bookings, verify driver PINs, and earn revenue.",
                  icon: Icons.ev_station_rounded,
                  value: "owner",
                  accentColor: const Color(0xFF00E5FF),
                ),

                const Spacer(),

                // Continue Button
                GlassButton(
                  text: "CONTINUE",
                  isLoading: _isLoading,
                  icon: Icons.arrow_forward_rounded,
                  color: selectedRole != null ? const Color(0xFF00E676) : null,
                  onPressed: selectedRole == null ? null : _handleContinue,
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
    required String title,
    required String badge,
    required String description,
    required IconData icon,
    required String value,
    required Color accentColor,
  }) {
    final bool isSelected = selectedRole == value;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      blur: 20,
      opacity: isSelected ? 0.22 : 0.08,
      borderColor: isSelected ? accentColor : Colors.white.withValues(alpha: 0.15),
      borderWidth: isSelected ? 2.0 : 1.0,
      glowColor: isSelected ? accentColor : null,
      glowSpread: isSelected ? 2 : 0,
      onTap: () => setState(() => selectedRole = value),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon Box
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected
                      ? accentColor.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? accentColor
                        : Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: isSelected ? accentColor : Colors.white70,
                ),
              ),

              const SizedBox(width: 16),

              // Title + Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      badge,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? accentColor : Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),

              // Check Indicator
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? accentColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? accentColor : Colors.white30,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Color(0xFF0B132B))
                    : null,
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}