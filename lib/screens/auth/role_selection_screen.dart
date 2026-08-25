import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

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

    setState(() {
      _isLoading = true;
    });

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
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Step Indicator Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FFF0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "STEP 2 OF 2",
                  style: TextStyle(
                    color: Color(0xFF00C853),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "Choose Your Role",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Select how you plan to use ChargeLink. You can also explore other features later.",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 36),

              // Role Card 1: EV Owner / Driver
              _buildRoleOption(
                title: "EV Owner & Driver",
                subtitle: "Discover nearby chargers, check live availability, and book slots seamlessly.",
                icon: Icons.electric_car_rounded,
                value: "customer",
                badgeText: "Recommended for drivers",
              ),

              const SizedBox(height: 20),

              // Role Card 2: Charger Owner / Host
              _buildRoleOption(
                title: "Charging Station Host",
                subtitle: "List your private or commercial charger, manage bookings, and earn passive income.",
                icon: Icons.ev_station_rounded,
                value: "owner",
                badgeText: "For station owners",
              ),

              const Spacer(),

              // Continue Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedRole == null
                      ? Colors.grey.shade400
                      : const Color(0xFF00C853),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: selectedRole == null ? 0 : 2,
                  shadowColor: const Color(0xFF00C853).withValues(alpha: 0.4),
                ),
                onPressed: (selectedRole == null || _isLoading)
                    ? null
                    : _handleContinue,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        "GET STARTED",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required String badgeText,
  }) {
    final bool isSelected = selectedRole == value;

    return InkWell(
      onTap: () {
        setState(() {
          selectedRole = value;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8FFF0) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF00C853) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF00C853).withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
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
                        ? const Color(0xFF00C853)
                        : const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: isSelected ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),

                const SizedBox(width: 16),

                // Title + Subtitle Header
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFF00C853)
                              : const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF1A6B3A)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),

                // Check Circle
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFF00C853) : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00C853)
                          : const Color(0xFFD1D5DB),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}