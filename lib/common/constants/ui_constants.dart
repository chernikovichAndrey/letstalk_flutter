import 'package:flutter/material.dart';

const Duration kAnimationDuration = Duration(milliseconds: 325);
const Duration kFastAnimationDuration = Duration(milliseconds: 200);
const Curve kAnimationCurve = Curves.easeInOutQuad;
final double kBorderRadiusValue = 16;
final BorderRadiusGeometry kBorderRadius =
    BorderRadius.circular(kBorderRadiusValue);
final List<BoxShadow> kShadow = [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.3),
    blurRadius: 10,
    spreadRadius: -2,
    offset: Offset(0, 0),
  ),
];

const mainColor = Color(0xFF121212);
