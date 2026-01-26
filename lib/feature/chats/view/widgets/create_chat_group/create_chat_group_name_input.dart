import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class CreateChatGroupNameInput extends StatelessWidget {
  final TextEditingController groupNameController;
  final VoidCallback onClearInput;
  final VoidCallback onPressCamera;

  const CreateChatGroupNameInput({
    super.key,
    required this.groupNameController,
    required this.onClearInput,
    required this.onPressCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: context.padding.top + 80,
        left: 16,
        right: 16,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: context.appColors.surfaceSecondary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onPressCamera,
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: context.appColors.telegramBlue.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: context.appColors.telegramBlue,
                  size: 44,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                autofocus: true,
                controller: groupNameController,
                maxLines: 1,
                style: TextStyle(
                  color: context.appColors.glassForeground,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: context.s.groupNameHint,
                  hintStyle: TextStyle(
                    color: context.appColors.glassForeground.withValues(
                      alpha: 0.5,
                    ),
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (groupNameController.text.isNotEmpty) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClearInput,
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: context.appColors.glassForeground.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
