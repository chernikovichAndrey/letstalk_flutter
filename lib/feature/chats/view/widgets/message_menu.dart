import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/chats/view/widgets/message_menu_item.dart';

class MessageMenu extends StatelessWidget {
  final bool isMe;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;

  const MessageMenu({
    super.key,
    required this.isMe,
    this.onCopy,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final backgroundColor = appColors.surfaceSecondary;
    final dividerColor = appColors.divider;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 250,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MessageMenuItem(
              title: context.s.copy,
              icon: Icons.file_copy_outlined,
              onTap: onCopy ?? () {},
            ),
            Divider(height: 1, indent: 12, endIndent: 12, color: dividerColor),
            if (isMe) ...[
              MessageMenuItem(
                title: context.s.edit,
                icon: Icons.edit_note_outlined,
                onTap: () {},
              ),
              Divider(
                height: 1,
                indent: 12,
                endIndent: 12,
                color: dividerColor,
              ),
            ],
            MessageMenuItem(
              title: context.s.forward,
              icon: Icons.reply_outlined,
              onTap: () {},
            ),
            Divider(height: 1, indent: 12, endIndent: 12, color: dividerColor),
            if (isMe)
              MessageMenuItem(
                title: context.s.delete,
                icon: Icons.delete_outline,
                onTap: onDelete ?? () {},
                isDestructive: true,
              ),
          ],
        ),
      ),
    );
  }
}
