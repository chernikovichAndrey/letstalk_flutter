import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_name_field.dart';

/// First/last name input card from Figma design "Name input"
/// (nodes 1068:37990 / 1068:38034). Renders a rounded card with two
/// stacked text fields separated by a thin divider. Adapts to light
/// and dark themes.
class CNameInputCard extends StatelessWidget {
  const CNameInputCard({
    required this.firstNameController,
    required this.lastNameController,
    this.firstNameHint,
    this.lastNameHint,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final String? firstNameHint;
  final String? lastNameHint;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
        isDark ? AppColors.messageDark : AppColors.messageLight;
    final dividerColor = isDark
        ? AppColors.messageLight.withValues(alpha: 0.1)
        : AppColors.messageDark.withValues(alpha: 0.1);
    final textColor =
        isDark ? AppColors.messageLight : AppColors.backgroundDark;
    final hintColor = isDark ? AppColors.grayDark : AppColors.grayLight;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          CNameField(
            controller: firstNameController,
            hintText: firstNameHint ?? context.s.firstName,
            textColor: textColor,
            hintColor: hintColor,
            autofocus: autofocus,
            textInputAction: TextInputAction.next,
            padding: const EdgeInsets.only(top: 16, bottom: 12),
          ),
          Container(height: 1, color: dividerColor),
          CNameField(
            controller: lastNameController,
            hintText: lastNameHint ?? context.s.lastName,
            textColor: textColor,
            hintColor: hintColor,
            textInputAction: TextInputAction.done,
            padding: const EdgeInsets.only(top: 12, bottom: 16),
          ),
        ],
      ),
    );
  }
}
