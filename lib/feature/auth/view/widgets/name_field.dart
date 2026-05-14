import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';

class NameField extends StatelessWidget {
  const NameField({
    required this.controller,
    required this.hintText,
    required this.textColor,
    required this.padding,
    this.autofocus = false,
    this.textInputAction = TextInputAction.next,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final Color textColor;
  final EdgeInsets padding;
  final bool autofocus;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        textInputAction: textInputAction,
        cursorColor: AppColors.brand,
        cursorWidth: 2,
        style: AppTypography.textMdRegular.copyWith(color: textColor),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hintText,
          hintStyle: AppTypography.textMdRegular.copyWith(
            color: AppColors.grayLight,
          ),
        ),
      ),
    );
  }
}
