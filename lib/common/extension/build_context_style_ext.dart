import 'package:flutter/material.dart';
import 'package:lets_talk/app/config/app_colors_extension.dart';
import 'package:lets_talk/common/l10n/generated/l10n.dart';

extension BuildContextExt on BuildContext {
  double get w => MediaQuery.sizeOf(this).width;
  double get h => MediaQuery.sizeOf(this).height;
  ThemeData get theme => Theme.of(this);
  TextTheme get text => Theme.of(this).textTheme;
  ColorScheme get color => Theme.of(this).colorScheme;
  AppColorsExtension get appColors => Theme.of(this).extension<AppColorsExtension>()!;
  S get s => S.of(this);
}
