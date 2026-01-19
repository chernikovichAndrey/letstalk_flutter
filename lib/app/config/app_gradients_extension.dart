import 'package:flutter/material.dart';

class AppGradientsExtension extends ThemeExtension<AppGradientsExtension> {
  final Gradient backgroundGradient;

  const AppGradientsExtension({
    required this.backgroundGradient,
  });

  @override
  AppGradientsExtension copyWith({
    Gradient? backgroundGradient,
  }) {
    return AppGradientsExtension(
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
    );
  }

  @override
  AppGradientsExtension lerp(ThemeExtension<AppGradientsExtension>? other, double t) {
    if (other is! AppGradientsExtension) return this;
    return AppGradientsExtension(
      backgroundGradient: Gradient.lerp(backgroundGradient, other.backgroundGradient, t)!,
    );
  }
}
