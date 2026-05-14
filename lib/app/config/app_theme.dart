import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lets_talk/app/config/app_colors_extension.dart';
import 'package:lets_talk/app/config/app_gradients_extension.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/ui_constants.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      fontFamily: GoogleFonts.inter().fontFamily,
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: mainColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: _textTheme,
      extensions: [
        AppColorsExtension(
          secondaryBackground: Colors.black.withValues(alpha: 0.05),
          telegramBlue: const Color(0xFF0088CC),
          destructive: AppColors.error,
          messageMeBubble: const Color(0xFFe2ffc8),
          messageOtherBubble: const Color(0xFFF2F2F7),
          messageMeText: AppColors.white,
          messageOtherText: Colors.black,
          messageMeTime: AppColors.white.withValues(alpha: 0.6),
          messageOtherTime: Colors.grey,
          inputFill: Colors.grey.withValues(alpha: 0.2),
          inputSecondaryFill: Colors.black.withValues(alpha: 0.1),
          glassBackground: AppColors.white.withValues(alpha: 0.4),
          glassForeground: Colors.black,
          glassButtonBackground: Colors.black.withValues(alpha: 0.1),
          divider: Colors.black.withValues(alpha: 0.1),
          hintText: Colors.black38,
          dateSeparatorBackground: const Color(0xFFE5E7EB),
          dateSeparatorText: Colors.black54,
          surfaceSecondary: const Color(0xFFF2F2F7),
          messageReadIcon: const Color(0xFF7bc665),
          skeletonColor: Colors.grey[200]!,
          skeletonShimmerColor: AppColors.white,
        ),
        const AppGradientsExtension(
          backgroundGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF80CBC4), // Teal 200
              Color(0xFF00695C), // Teal 800
            ],
          ),
        ),
      ],
    );
  }

  static ThemeData get dark {
    return ThemeData(
      fontFamily: GoogleFonts.inter().fontFamily,
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: mainColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: _textTheme,
      extensions: [
        AppColorsExtension(
          secondaryBackground: AppColors.white.withValues(alpha: 0.1),
          telegramBlue: const Color(0xFF0088CC),
          destructive: AppColors.error,
          messageMeBubble: const Color(0xFF537AA3),
          messageOtherBubble: const Color(0xFF2B2D31),
          messageMeText: AppColors.white,
          messageOtherText: AppColors.white,
          messageMeTime: AppColors.white.withValues(alpha: 0.6),
          messageOtherTime: AppColors.white.withValues(alpha: 0.6),
          inputFill: Colors.grey.withValues(alpha: 0.2),
          inputSecondaryFill: AppColors.white.withValues(alpha: 0.1),
          glassBackground: Colors.black.withValues(alpha: 0.4),
          glassForeground: AppColors.white,
          glassButtonBackground: AppColors.white.withValues(alpha: 0.1),
          divider: Colors.white10,
          hintText: Colors.white38,
          dateSeparatorBackground: const Color(0xFF2B2D31),
          dateSeparatorText: Colors.white70,
          surfaceSecondary: Colors.black,
          messageReadIcon: AppColors.white,
          skeletonColor: Colors.white10,
          skeletonShimmerColor: Colors.white30,
        ),
        const AppGradientsExtension(
          backgroundGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7E57C2), // Deep Purple 400
              Color(0xFF311B92), // Deep Purple 900
            ],
          ),
        ),
      ],
    );
  }

  static TextTheme get _textTheme {
    return GoogleFonts.interTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          height: 1.12,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.16,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.22,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.29,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.33,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.27,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.33,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.45,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.43,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.33,
        ),
      ),
    );
  }
}
