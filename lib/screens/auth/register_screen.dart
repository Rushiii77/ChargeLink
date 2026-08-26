import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../widgets/glass/glass_background.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/glass/glass_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showToast("Please fill in all fields", isError: true);
      return;
    }

    if (password != confirmPassword) {
      _showToast("Passwords do not match", isError: true);
      return;
    }

    if (password.length < 6) {
      _showToast("Password must be at least 6 characters", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      if (!mounted) return;

      _showToast("Account Created! Select your role.");
      Navigator.pushReplacementNamed(context, '/role-selection');
    } on FirebaseAuthException catch (e) {
      String message = "Registration Failed";
      switch (e.code) {
        case 'email-already-in-use':
          message = "This email is already registered";
          break;
        case 'invalid-email':
          message = "Please provide a valid email";
          break;
        case 'weak-password':
          message = "Password is too weak";
          break;
        default:
          if (e.message != null) message = e.message!;
      }
      _showToast(message, isError: true);
    } catch (e) {
      _showToast(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showToast(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent.shade700 : const Color(0xFF00E676),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // Header
                  GlassContainer(
                    width: 72,
                    height: 72,
                    borderRadius: BorderRadius.circular(22),
                    blur: 16,
                    opacity: 0.15,
                    glowColor: const Color(0xFF00E5FF),
                    glowSpread: 2,
                    child: const Center(
                      child: Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 36,
                        color: Color(0xFF00E5FF),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Join the decentralized EV charging network",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Frosted Form Card
                  GlassContainer(
                    padding: const EdgeInsets.all(22),
                    borderRadius: BorderRadius.circular(28),
                    blur: 24,
                    opacity: 0.12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GlassTextField(
                          controller: _nameController,
                          labelText: "Full Name",
                          hintText: "Elon Musk",
                          prefixIcon: Icons.person_outline_rounded,
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 14),

                        GlassTextField(
                          controller: _emailController,
                          labelText: "Email Address",
                          hintText: "driver@ev.com",
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 14),

                        GlassTextField(
                          controller: _phoneController,
                          labelText: "Phone Number",
                          hintText: "+91 98765 43210",
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 14),

                        GlassTextField(
                          controller: _passwordController,
                          labelText: "Password",
                          hintText: "••••••••",
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _hidePassword,
                          textInputAction: TextInputAction.next,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.white60,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _hidePassword = !_hidePassword),
                          ),
                        ),

                        const SizedBox(height: 14),

                        GlassTextField(
                          controller: _confirmPasswordController,
                          labelText: "Confirm Password",
                          hintText: "••••••••",
                          prefixIcon: Icons.lock_reset_rounded,
                          obscureText: _hideConfirmPassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _registerUser(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _hideConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.white60,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _hideConfirmPassword = !_hideConfirmPassword),
                          ),
                        ),

                        const SizedBox(height: 24),

                        GlassButton(
                          text: "CREATE ACCOUNT",
                          isLoading: _isLoading,
                          icon: Icons.flash_on_rounded,
                          onPressed: _registerUser,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Back to Login
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    borderRadius: BorderRadius.circular(24),
                    blur: 16,
                    opacity: 0.08,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Already registered?",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF00E676),
                            padding: const EdgeInsets.only(left: 8),
                          ),
                          child: const Text(
                            "Sign In",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}