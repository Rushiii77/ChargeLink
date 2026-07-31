import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: FadeTransition(
          opacity: _animation,
          child: ScaleTransition(
            scale: _animation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Icon(
                  Icons.ev_station,
                  size: 100,
                  color: Colors.green,
                ),

                const SizedBox(height: 25),

                const Text(
                  "ChargeLink",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Powering Peer-to-Peer EV Charging",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 80),

                const CircularProgressIndicator(),

                const SizedBox(height: 15),

                const Text(
                  "Loading...",
                  style: TextStyle(fontSize: 15),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
