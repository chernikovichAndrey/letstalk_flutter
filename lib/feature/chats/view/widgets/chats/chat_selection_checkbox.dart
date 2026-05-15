import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';

class ChatSelectionCheckbox extends StatelessWidget {
  final bool isSelected;

  const ChatSelectionCheckbox({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? AppColors.white.withValues(alpha: 0.2)
        : AppColors.messageDark.withValues(alpha: 0.2);

    return SizedBox.square(
      dimension: 20,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brand : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? null : Border.all(color: borderColor),
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                size: 14,
                color: AppColors.white,
              )
            : null,
      ),
    );
  }
}
