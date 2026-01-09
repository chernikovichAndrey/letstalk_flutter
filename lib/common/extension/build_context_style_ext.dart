import 'package:flutter/material.dart';
import 'package:lets_talk/common/l10n/generated/l10n.dart';

extension BuildContextExt on BuildContext {
  double get w => MediaQuery.sizeOf(this).width;
  double get h => MediaQuery.sizeOf(this).height;
  ThemeData get theme => Theme.of(this);
  S get s => S.of(this);
}
