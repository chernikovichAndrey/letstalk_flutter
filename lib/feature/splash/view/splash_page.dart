import 'package:flutter/material.dart';
import 'package:lets_talk/common/widget/gradient_background.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
