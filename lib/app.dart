import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/customer/booking/my_bookings_screen.dart';
import 'screens/customer/home/customer_home.dart';
import 'screens/customer/session/active_session_screen.dart';
import 'screens/customer/trip/trip_planner_screen.dart';
import 'screens/owner/home/owner_home.dart';
import 'screens/splash/splash_screen.dart';

class ChargeLinkApp extends StatelessWidget {
  const ChargeLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChargeLink',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/role-selection': (context) => const RoleSelectionScreen(),
        '/customer-home': (context) => const CustomerHome(),
        '/owner-home': (context) => const OwnerHome(),
        '/my-bookings': (context) => const MyBookingsScreen(),
        '/active-session': (context) => const ActiveSessionScreen(),
        '/trip-planner': (context) => const TripPlannerScreen(),
      },
    );
  }
}