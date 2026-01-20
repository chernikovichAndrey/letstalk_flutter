import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color secondaryBackground;
  final Color telegramBlue;
  final Color destructive;
  final Color messageMeBubble;
  final Color messageOtherBubble;
  final Color messageMeText;
  final Color messageOtherText;
  final Color messageMeTime;
  final Color messageOtherTime;
  final Color inputFill;
  final Color inputSecondaryFill;
  final Color glassBackground;
  final Color glassForeground;
  final Color glassButtonBackground;
  final Color divider;
  final Color hintText;
  final Color dateSeparatorBackground;
  final Color dateSeparatorText;
  final Color surfaceSecondary;
  final Color messageReadIcon;
  final Color skeletonColor;
  final Color skeletonShimmerColor;

  const AppColorsExtension({
    required this.secondaryBackground,
    required this.telegramBlue,
    required this.destructive,
    required this.messageMeBubble,
    required this.messageOtherBubble,
    required this.messageMeText,
    required this.messageOtherText,
    required this.messageMeTime,
    required this.messageOtherTime,
    required this.inputFill,
    required this.inputSecondaryFill,
    required this.glassBackground,
    required this.glassForeground,
    required this.glassButtonBackground,
    required this.divider,
    required this.hintText,
    required this.dateSeparatorBackground,
    required this.dateSeparatorText,
    required this.surfaceSecondary,
    required this.messageReadIcon,
    required this.skeletonColor,
    required this.skeletonShimmerColor,
  });

  @override
  AppColorsExtension copyWith({
    Color? secondaryBackground,
    Color? telegramBlue,
    Color? destructive,
    Color? messageMeBubble,
    Color? messageOtherBubble,
    Color? messageMeText,
    Color? messageOtherText,
    Color? messageMeTime,
    Color? messageOtherTime,
    Color? inputFill,
    Color? inputSecondaryFill,
    Color? glassBackground,
    Color? glassForeground,
    Color? glassButtonBackground,
    Color? divider,
    Color? hintText,
    Color? dateSeparatorBackground,
    Color? dateSeparatorText,
    Color? surfaceSecondary,
    Color? messageReadIcon,
    Color? skeletonColor,
    Color? skeletonShimmerColor,
  }) {
    return AppColorsExtension(
      secondaryBackground: secondaryBackground ?? this.secondaryBackground,
      telegramBlue: telegramBlue ?? this.telegramBlue,
      destructive: destructive ?? this.destructive,
      messageMeBubble: messageMeBubble ?? this.messageMeBubble,
      messageOtherBubble: messageOtherBubble ?? this.messageOtherBubble,
      messageMeText: messageMeText ?? this.messageMeText,
      messageOtherText: messageOtherText ?? this.messageOtherText,
      messageMeTime: messageMeTime ?? this.messageMeTime,
      messageOtherTime: messageOtherTime ?? this.messageOtherTime,
      inputFill: inputFill ?? this.inputFill,
      inputSecondaryFill: inputSecondaryFill ?? this.inputSecondaryFill,
      glassBackground: glassBackground ?? this.glassBackground,
      glassForeground: glassForeground ?? this.glassForeground,
      glassButtonBackground: glassButtonBackground ?? this.glassButtonBackground,
      divider: divider ?? this.divider,
      hintText: hintText ?? this.hintText,
      dateSeparatorBackground: dateSeparatorBackground ?? this.dateSeparatorBackground,
      dateSeparatorText: dateSeparatorText ?? this.dateSeparatorText,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      messageReadIcon: messageReadIcon ?? this.messageReadIcon,
      skeletonColor: skeletonColor ?? this.skeletonColor,
      skeletonShimmerColor: skeletonShimmerColor ?? this.skeletonShimmerColor,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      secondaryBackground: Color.lerp(secondaryBackground, other.secondaryBackground, t)!,
      telegramBlue: Color.lerp(telegramBlue, other.telegramBlue, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      messageMeBubble: Color.lerp(messageMeBubble, other.messageMeBubble, t)!,
      messageOtherBubble: Color.lerp(messageOtherBubble, other.messageOtherBubble, t)!,
      messageMeText: Color.lerp(messageMeText, other.messageMeText, t)!,
      messageOtherText: Color.lerp(messageOtherText, other.messageOtherText, t)!,
      messageMeTime: Color.lerp(messageMeTime, other.messageMeTime, t)!,
      messageOtherTime: Color.lerp(messageOtherTime, other.messageOtherTime, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      inputSecondaryFill: Color.lerp(inputSecondaryFill, other.inputSecondaryFill, t)!,
      glassBackground: Color.lerp(glassBackground, other.glassBackground, t)!,
      glassForeground: Color.lerp(glassForeground, other.glassForeground, t)!,
      glassButtonBackground: Color.lerp(glassButtonBackground, other.glassButtonBackground, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      hintText: Color.lerp(hintText, other.hintText, t)!,
      dateSeparatorBackground: Color.lerp(dateSeparatorBackground, other.dateSeparatorBackground, t)!,
      dateSeparatorText: Color.lerp(dateSeparatorText, other.dateSeparatorText, t)!,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      messageReadIcon: Color.lerp(messageReadIcon, other.messageReadIcon, t)!,
      skeletonColor: Color.lerp(skeletonColor, other.skeletonColor, t)!,
      skeletonShimmerColor: Color.lerp(skeletonShimmerColor, other.skeletonShimmerColor, t)!,
    );
  }
}
