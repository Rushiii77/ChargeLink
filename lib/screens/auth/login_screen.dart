import 'package:flutter/material.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/inputs/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              const SizedBox(height: 40),

              const Icon(
                Icons.ev_station,
                size: 90,
                color: Colors.green,
              ),

              const SizedBox(height: 20),

              const Text(
                "Welcome Back!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Login to continue",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              CustomTextField(
                controller: _emailController,
                labelText: "Email",
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
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

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: const Text("Forgot Password?"),
                ),
              ),

              const SizedBox(height: 20),

              PrimaryButton(
                text: "LOGIN",
                onPressed: () {
                  // Login functionality will be added later
                },
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text("Create Account"),
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