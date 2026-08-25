import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your email address'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.resetPassword(email: email);
      if (!mounted) return;
      setState(() => _emailSent = true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Failed to send reset email'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // Green gradient top
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF1A6B3A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Back button + title in header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Reset Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // White card body
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(28),
                      child: _emailSent
                          ? _buildSuccessState()
                          : _buildFormState(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFFE8FFF0),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 52,
            color: Color(0xFF00C853),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Check Your Email!',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'We\'ve sent a password reset link to\n${_emailController.text.trim()}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00C853),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Back to Login',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildFormState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFE8FFF0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.lock_reset_outlined,
            size: 38,
            color: Color(0xFF00C853),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'No worries! Enter your registered email address and we\'ll send you a link to reset your password.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 36),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            prefixIcon: const Icon(Icons.email_outlined,
                color: Color(0xFF00C853)),
            labelText: 'Email Address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFF00C853), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00C853),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
          onPressed: _isLoading ? null : _resetPassword,
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  'Send Reset Link',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Back to Login'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }
}
