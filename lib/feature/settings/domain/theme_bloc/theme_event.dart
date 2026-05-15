import 'package:flutter/material.dart';

abstract class ThemeEvent {}

class ThemeChanged extends ThemeEvent {
  final ThemeMode mode;

  ThemeChanged(this.mode);
}

class LoadSavedTheme extends ThemeEvent {}
