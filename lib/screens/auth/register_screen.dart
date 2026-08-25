import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';

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

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      if (!mounted) return;

      _showToast("Account Created Successfully! Let's choose your role.");
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showToast(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : const Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Green Gradient Header
            Container(
              width: double.infinity,
              height: size.height * 0.24,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00C853), Color(0xFF1A6B3A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Join ChargeLink and start charging smarter",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Form Container
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Name Field
                  _buildTextField(
                    controller: _nameController,
                    icon: Icons.person_outline_rounded,
                    label: "Full Name",
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 16),

                  // Email Field
                  _buildTextField(
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    label: "Email Address",
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 16),

                  // Phone Field
                  _buildTextField(
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    label: "Phone Number",
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _hidePassword,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      icon: Icons.lock_outline_rounded,
                      label: "Password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF6B7280),
                        ),
                        onPressed: () {
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _hideConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _registerUser(),
                    decoration: _inputDecoration(
                      icon: Icons.lock_reset_rounded,
                      label: "Confirm Password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hideConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF6B7280),
                        ),
                        onPressed: () {
                          setState(() {
                            _hideConfirmPassword = !_hideConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Register Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 2,
                      shadowColor: const Color(0xFF00C853).withValues(alpha: 0.4),
                    ),
                    onPressed: _isLoading ? null : _registerUser,
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
                            "CREATE ACCOUNT",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                  ),

                  const SizedBox(height: 20),

                  // Back to Login Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF00C853),
                        ),
                        child: const Text(
                          "Sign In",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: _inputDecoration(icon: icon, label: label),
    );
  }

  InputDecoration _inputDecoration({
    required IconData icon,
    required String label,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF00C853),
      ),
      suffixIcon: suffixIcon,
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF6B7280)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF00C853),
          width: 2,
        ),
      ),
    );
  }
}