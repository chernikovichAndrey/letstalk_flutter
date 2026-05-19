import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/message_menu_item.dart';

class MessageMenu extends StatelessWidget {
  final bool isMe;
  final VoidCallback? onCopy;
  final VoidCallback onReply;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
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
    final isDark = context.theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark.withValues(alpha: 0.85)
        : AppColors.white.withValues(alpha: 0.7);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : const Color(0xFF424242).withValues(alpha: 0.05);

    final items = _buildItems(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF232323).withValues(alpha: 0.06),
                offset: const Offset(0, 3),
                blurRadius: 7,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12.5, sigmaY: 12.5),
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: SizedBox(
                    width: 210,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = 0; i < items.length; i++) ...[
                          items[i],
                          if (i < items.length - 1)
                            Container(height: 1, color: dividerColor),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildItems(BuildContext context) {
    final items = <Widget>[];

    items.add(MessageMenuItem(
      title: context.s.reply,
      iconAsset: 'assets/icons/message_forward.svg',
      mirrorIcon: true,
      onTap: onReply,
    ));

    if (onCopy != null) {
      items.add(MessageMenuItem(
        title: context.s.copy,
        iconAsset: 'assets/icons/message_copy.svg',
        onTap: onCopy!,
      ));
    }

    if (onDownload != null) {
      items.add(MessageMenuItem(
        title: context.s.download,
        iconAsset: 'assets/icons/message_download.svg',
        onTap: onDownload!,
      ));
    }

    if (onEdit != null) {
      items.add(MessageMenuItem(
        title: context.s.edit,
        iconAsset: 'assets/icons/message_edit.svg',
        onTap: onEdit!,
      ));
    }

    items.add(MessageMenuItem(
      title: context.s.forward,
      iconAsset: 'assets/icons/message_forward.svg',
      onTap: onForward,
    ));

    if (isMe) {
      items.add(MessageMenuItem(
        title: context.s.delete,
        iconAsset: 'assets/icons/message_delete.svg',
        isDestructive: true,
        onTap: onDelete,
      ));
    }

    return items;
  }
}
