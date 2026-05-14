import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brand,
      body: Center(
        child: Image.asset(
          'assets/images/splash_icon_small.png',
        ),
      ),
    );
  }
}
