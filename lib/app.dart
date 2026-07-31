import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/customer/home/customer_home.dart';


class ChargeLinkApp extends StatelessWidget {
  const ChargeLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'ChargeLink',

      theme: AppTheme.lightTheme,

      home: const RegisterScreen(),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/role-selection': (context) => const RoleSelectionScreen(),
      },
      
    );
  }
}