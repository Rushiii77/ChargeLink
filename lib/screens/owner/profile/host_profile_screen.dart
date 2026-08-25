import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';

class HostProfileScreen extends StatefulWidget {
  const HostProfileScreen({super.key});

  @override
  State<HostProfileScreen> createState() => _HostProfileScreenState();
}

class _HostProfileScreenState extends State<HostProfileScreen> {
  final AuthService _authService = AuthService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          _nameController.text = data['name'] ?? '';
          _phoneController.text = data['phone'] ?? '';
        }
      } catch (_) {}
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    final user = _authService.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: Color(0xFF00C853),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update: $e"),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Station Host Profile",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar & Verified Badge
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8FFF0),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF00C853), width: 2),
                          ),
                          child: const Icon(
                            Icons.storefront_rounded,
                            size: 42,
                            color: Color(0xFF00C853),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8FFF0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, size: 16, color: Color(0xFF00C853)),
                              SizedBox(width: 4),
                              Text(
                                "VERIFIED HOST",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00C853),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Profile Form Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Host Information",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: "Host / Business Name",
                          controller: _nameController,
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: "Email Address",
                          controller: _emailController,
                          icon: Icons.email_outlined,
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: "Contact Phone",
                          controller: _phoneController,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Payout info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Payout Settings",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8FFF0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.account_balance_rounded, color: Color(0xFF00C853), size: 22),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Direct UPI / Bank Transfer",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                                  ),
                                  Text(
                                    "Earnings deposited weekly",
                                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF00C853), size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Save Profile Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                      ),
                      onPressed: _isSaving ? null : _saveProfile,
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text("SAVE PROFILE CHANGES", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly ? const Color(0xFFF5F7FA) : Colors.white,
            prefixIcon: Icon(icon, color: const Color(0xFF00C853), size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF00C853), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

