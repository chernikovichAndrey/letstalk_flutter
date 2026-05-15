import 'package:flutter/material.dart';

class ThemeState {
  final ThemeMode mode;

  const ThemeState({required this.mode});

  ThemeState copyWith({ThemeMode? mode}) {
    return ThemeState(mode: mode ?? this.mode);
  }
}
