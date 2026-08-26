import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
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

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar
                Row(
                  children: [
                    GlassContainer(
                      width: 44,
                      height: 44,
                      borderRadius: BorderRadius.circular(14),
                      blur: 16,
                      opacity: 0.1,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      "Station Host Profile",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Host Hero Card
                GlassContainer(
                  padding: const EdgeInsets.all(22),
                  borderRadius: BorderRadius.circular(28),
                  blur: 20,
                  opacity: 0.14,
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00E676), Color(0xFF00E5FF)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E676).withValues(alpha: 0.35),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.person_rounded, size: 36, color: Color(0xFF0B132B)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? "Station Host Partner",
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? "host@chargelink.com",
                              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.65)),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.4)),
                              ),
                              child: const Text(
                                "✓ Verified Host Operator",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00E676),
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

                // Settings Form
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  borderRadius: BorderRadius.circular(24),
                  blur: 20,
                  opacity: 0.12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Business & Payout Information",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      GlassTextField(
                        controller: _businessNameController,
                        labelText: "Business / Entity Name",
                        prefixIcon: Icons.business_rounded,
                      ),
                      const SizedBox(height: 14),
                      GlassTextField(
                        controller: _phoneController,
                        labelText: "Support Phone Number",
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),
                      GlassTextField(
                        controller: _upiController,
                        labelText: "Payout UPI ID / VPA",
                        prefixIcon: Icons.account_balance_wallet_outlined,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                GlassButton(
                  text: "SAVE PROFILE & PAYOUT SETTINGS",
                  isLoading: _isSaving,
                  icon: Icons.save_rounded,
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
