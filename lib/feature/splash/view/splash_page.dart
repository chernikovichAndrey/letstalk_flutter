import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black,
                Color(0xFF2C1F16), // Dark brownish
                Color(0xFF5D4037), // Lighter brown/orange tint
              ],
            ),
          ),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
