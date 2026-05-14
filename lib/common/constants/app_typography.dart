import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand typography tokens from Figma design system (section "01. Typography").
/// Roboto is the primary type family. Prefer these tokens for new UI work
/// over ad-hoc `TextStyle(fontSize: ..., fontWeight: ...)` declarations.
class AppTypography {
  AppTypography._();

  static String? get fontFamily => GoogleFonts.roboto().fontFamily;

  // Heading sm — 24px / 1.25
  static TextStyle get headingSmRegular => GoogleFonts.roboto(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 1.25,
  );
  static TextStyle get headingSmMedium => GoogleFonts.roboto(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );

  // Heading xs — 20px / 1.2
  static TextStyle get headingXsRegular => GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );
  static TextStyle get headingXsMedium => GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  // Text lg — 18px / 1.2
  static TextStyle get textLgRegular => GoogleFonts.roboto(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );
  static TextStyle get textLgMedium => GoogleFonts.roboto(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  // Text md — 16px / 1.25
  static TextStyle get textMdRegular => GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.25,
  );
  static TextStyle get textMdMedium => GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );
  static TextStyle get textMdSemiBold => GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  // Text sm — 13px / 1.25
  static TextStyle get textSmMedium => GoogleFonts.roboto(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );

  // Text xs — 12px / 1.3
  static TextStyle get textXsRegular => GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );
  static TextStyle get textXsMedium => GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
}
