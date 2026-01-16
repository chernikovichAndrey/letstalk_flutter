import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';

class ChatListItem extends StatelessWidget {
  final Chat chat;
  final bool isTyping;
  final VoidCallback? onTap;

  const ChatListItem({
    super.key,
    required this.chat,
    this.isTyping = false,
    this.onTap,
  });

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      
      if (dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day) {
        // Today: HH:mm
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else {
        // Other days: dd.MM.yy
        return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${(dateTime.year % 100).toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CAvatar(
              imageUrl: chat.avatar,
              name: chat.title,
              radius: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat.title ?? context.s.noTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(chat.lastMessageAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isTyping ? 'Typing...' : (chat.lastMessageText ?? ''),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: context.appColors.messageMeBubble,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(minWidth: 20),
                          child: Center(
                            child: Text(
                              chat.unreadCount.toString(),
                              style: TextStyle(
                                color: context.appColors.messageMeText,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
