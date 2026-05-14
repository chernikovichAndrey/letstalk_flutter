import 'package:flutter/material.dart';

/// Brand color palette from Figma design system (section "02. Colors").
/// Prefer these constants for new UI work over hardcoded `Color(0xFF...)` values.
class AppColors {
  AppColors._();

  // Primary / background
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF191919);

  // Gray scale
  static const Color messageDark = Color(0xFF2E2E2E);
  static const Color grayDark = Color(0xFF4C4C4C);
  static const Color grayLight = Color(0xFFBEBEBE);
  static const Color messageLight = Color(0xFFF1F1F1);

  // Button
  static const Color brand = Color(0xFFC96A3A);
  static const Color white = Color(0xFFFFFFFF);

  // Error
  static const Color error = Color(0xFFC63535);

  // Additional
  static const Color orangeLight = Color(0xFFF2C4A6);
}
