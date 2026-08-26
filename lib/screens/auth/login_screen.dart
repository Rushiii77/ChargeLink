import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../widgets/glass/glass_background.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/glass/glass_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _hidePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showToast("Please enter your email and password", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      final role = await _authService.getUserRole(userCredential.user!.uid);

      if (!mounted) return;

      if (role == 'owner') {
        Navigator.pushReplacementNamed(context, '/owner-home');
      } else if (role == 'customer') {
        Navigator.pushReplacementNamed(context, '/customer-home');
      } else {
        Navigator.pushReplacementNamed(context, '/role-selection');
      }
    } on FirebaseAuthException catch (e) {
      String message = "Login Failed";
      if (e.code == 'user-not-found') {
        message = "No account found with this email";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email format";
      } else if (e.message != null) {
        message = e.message!;
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Floating Crystal Logo Icon
                  GlassContainer(
                    width: 80,
                    height: 80,
                    borderRadius: BorderRadius.circular(24),
                    blur: 20,
                    opacity: 0.15,
                    glowColor: const Color(0xFF00E676),
                    glowSpread: 2,
                    child: const Center(
                      child: Icon(
                        Icons.ev_station_rounded,
                        size: 40,
                        color: Color(0xFF00E676),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Sign in to your ChargeLink quantum hub",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Frosted Glass Form Card
                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    borderRadius: BorderRadius.circular(28),
                    blur: 24,
                    opacity: 0.12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GlassTextField(
                          controller: _emailController,
                          labelText: "Email Address",
                          hintText: "driver@chargelink.com",
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 16),

                        GlassTextField(
                          controller: _passwordController,
                          labelText: "Password",
                          hintText: "••••••••",
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _hidePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _loginUser(),
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

                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/forgot-password');
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF00E676),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        GlassButton(
                          text: "SIGN IN",
                          isLoading: _isLoading,
                          icon: Icons.bolt_rounded,
                          onPressed: _loginUser,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Create Account Row in Glass Pill
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    borderRadius: BorderRadius.circular(24),
                    blur: 16,
                    opacity: 0.08,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF00E676),
                            padding: const EdgeInsets.only(left: 8),
                          ),
                          child: const Text(
                            "Create Account",
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