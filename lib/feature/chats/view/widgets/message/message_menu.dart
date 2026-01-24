import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/message_menu_item.dart';

class MessageMenu extends StatelessWidget {
  final bool isMe;
  final VoidCallback? onCopy;
  final VoidCallback onReply;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onForward;
  final VoidCallback? onDownload;

  const MessageMenu({
    super.key,
    required this.isMe,
    required this.onCopy,
    required this.onReply,
    required this.onDelete,
    required this.onEdit,
    required this.onForward,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final dividerColor = appColors.divider;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 250,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MessageMenuItem(
                title: context.s.reply,
                icon: Icons.reply_outlined,
                onTap: onReply,
            ),
            Divider(height: 1, indent: 12, endIndent: 12, color: dividerColor),
            if (onCopy != null) ...[
              MessageMenuItem(
                title: context.s.copy,
                icon: Icons.file_copy_outlined,
                onTap: onCopy!,
              ),
              Divider(height: 1, indent: 12, endIndent: 12, color: dividerColor),
            ],
            if (onDownload != null) ...[
              MessageMenuItem(
                title: context.s.download,
                icon: Icons.download_outlined,
                onTap: onDownload!,
              ),
              Divider(
                height: 1,
                indent: 12,
                endIndent: 12,
                color: dividerColor,
              ),
            ],
            if (isMe) ...[
              MessageMenuItem(
                title: context.s.edit,
                icon: Icons.edit_note_outlined,
                onTap: onEdit,
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
              icon: Icons.forward_outlined,
              onTap: onForward,
            ),
            Divider(height: 1, indent: 12, endIndent: 12, color: dividerColor),
            if (isMe)
              MessageMenuItem(
                title: context.s.delete,
                icon: Icons.delete_outline,
                onTap: onDelete,
                isDestructive: true,
              ),
          ],
        ),
      ),
    );
  }
}
