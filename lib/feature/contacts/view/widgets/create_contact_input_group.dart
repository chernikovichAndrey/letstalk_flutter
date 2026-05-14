import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class CreatePhoneInputGroup extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;

  const CreatePhoneInputGroup({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          TextField(
            controller: firstNameController,
            style: AppTypography.textMdRegular,
            decoration: InputDecoration(
              hintText: context.s.firstName,
              hintStyle: AppTypography.textMdRegular.copyWith(
                color: context.appColors.hintText,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
              border: InputBorder.none,
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: context.appColors.divider,
          ),
          TextField(
            controller: lastNameController,
            style: AppTypography.textMdRegular,
            decoration: InputDecoration(
              hintText: context.s.lastName,
              hintStyle: AppTypography.textMdRegular.copyWith(
                color: context.appColors.hintText,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}
