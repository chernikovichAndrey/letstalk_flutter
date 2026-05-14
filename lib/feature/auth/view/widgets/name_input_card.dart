import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/auth/view/widgets/name_field.dart';

class NameInputCard extends StatelessWidget {
  const NameInputCard({
    required this.firstNameController,
    required this.lastNameController,
    required this.backgroundColor,
    required this.dividerColor,
    required this.textColor,
    super.key,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final Color backgroundColor;
  final Color dividerColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          NameField(
            controller: firstNameController,
            hintText: context.s.authProfileFirstNameHint,
            textColor: textColor,
            autofocus: true,
            textInputAction: TextInputAction.next,
            padding: const EdgeInsets.only(top: 16, bottom: 12),
          ),
          Container(
            height: 1,
            color: dividerColor,
          ),
          NameField(
            controller: lastNameController,
            hintText: context.s.authProfileLastNameHint,
            textColor: textColor,
            textInputAction: TextInputAction.done,
            padding: const EdgeInsets.only(top: 12, bottom: 16),
          ),
        ],
      ),
    );
  }
}
