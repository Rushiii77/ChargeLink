import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/inputs/custom_text_field.dart';

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
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
        ),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 6 characters"),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account Created Successfully"),
        ),
      );

      Navigator.pushReplacementNamed(context, '/role-selection');
    } on FirebaseAuthException catch (e) {
      String message = "Registration Failed";

      switch (e.code) {
        case 'email-already-in-use':
          message = "Email already registered";
          break;
        case 'invalid-email':
          message = "Invalid email address";
          break;
        case 'weak-password':
          message = "Password is too weak";
          break;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),

              const Icon(
                Icons.person_add_alt_1,
                size: 90,
                color: Colors.green,
              ),

              const SizedBox(height: 20),

              const Text(
                "Create Account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Join ChargeLink Today",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              CustomTextField(
                controller: _nameController,
                labelText: "Full Name",
                prefixIcon: Icons.person,
              ),

              const SizedBox(height: 20),

              CustomTextField(
                controller: _emailController,
                labelText: "Email",
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              CustomTextField(
                controller: _phoneController,
                labelText: "Phone Number",
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 20),

              CustomTextField(
                controller: _passwordController,
                labelText: "Password",
                prefixIcon: Icons.lock,
                obscureText: _hidePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _hidePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _hidePassword = !_hidePassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              CustomTextField(
                controller: _confirmPasswordController,
                labelText: "Confirm Password",
                prefixIcon: Icons.lock_outline,
                obscureText: _hideConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _hideConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _hideConfirmPassword = !_hideConfirmPassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 30),

              PrimaryButton(
                text: _isLoading
                    ? "CREATING ACCOUNT..."
                    : "CREATE ACCOUNT",
                onPressed: _isLoading
                    ? null
                    : () {
                        _registerUser();
                      },
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Login"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}