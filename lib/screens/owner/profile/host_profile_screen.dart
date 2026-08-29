import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../services/theme_service.dart';
import '../../../widgets/glass/glass_background.dart';
import '../../../widgets/glass/glass_button.dart';
import '../../../widgets/glass/glass_container.dart';
import '../../../widgets/glass/glass_text_field.dart';

class HostProfileScreen extends StatefulWidget {
  const HostProfileScreen({super.key});

  @override
  State<HostProfileScreen> createState() => _HostProfileScreenState();
}

class _HostProfileScreenState extends State<HostProfileScreen> {
  final AuthService _authService = AuthService();

  final _businessNameController = TextEditingController(text: "ChargeLink Partner Network");
  final _phoneController = TextEditingController(text: "+91 98765 43210");
  final _upiController = TextEditingController(text: "host@okhdfcbank");

  bool _isSaving = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Host profile and payout settings updated!"),
        backgroundColor: Color(0xFF00E676),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final isDark = ThemeService.isDark(context);

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar
                Row(
                  children: [
                    GlassContainer(
                      tier: GlassTier.tertiary,
                      width: 44,
                      height: 44,
                      borderRadius: BorderRadius.circular(14),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          size: 18,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      "Station Host Profile",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Host Hero Card
                GlassContainer(
                  tier: GlassTier.secondary,
                  padding: const EdgeInsets.all(22),
                  borderRadius: BorderRadius.circular(28),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF00E676), Color(0xFF00E5FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.storefront_rounded, color: Color(0xFF0B132B), size: 34),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? "Verified Host Partner",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? "host@chargelink.com",
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white.withValues(alpha: 0.65) : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676).withValues(alpha: isDark ? 0.2 : 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "● Station Host Tier 1",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFF00E676) : const Color(0xFF00A040),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Form Details
                Text(
                  "Business & Payout Details",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),

                GlassContainer(
                  tier: GlassTier.secondary,
                  padding: const EdgeInsets.all(18),
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    children: [
                      GlassTextField(
                        controller: _businessNameController,
                        labelText: "Station Commercial Name",
                        prefixIcon: Icons.business_rounded,
                      ),
                      const SizedBox(height: 14),
                      GlassTextField(
                        controller: _phoneController,
                        labelText: "Host Contact Number",
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_rounded,
                      ),
                      const SizedBox(height: 14),
                      GlassTextField(
                        controller: _upiController,
                        labelText: "Payout UPI VPA (Direct Bank Deposit)",
                        prefixIcon: Icons.account_balance_rounded,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                GlassButton(
                  text: "SAVE PROFILE CHANGES",
                  isLoading: _isSaving,
                  icon: Icons.check_circle_rounded,
                  onPressed: _saveProfile,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
