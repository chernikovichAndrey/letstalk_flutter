import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final timeFormat = DateFormat('HH:mm');
    final DateTime? createdAt = DateTime.tryParse(message.createdAt);
    final String time = createdAt != null ? timeFormat.format(createdAt.toLocal()) : '';

    Color backgroundColor;
    Color textColor;
    Color timeColor;
    Color? checkReadColor;
    Color? checkUnreadColor;

    if (isMe) {
      if (isDark) {
        backgroundColor = const Color(0xFF537AA3);
        textColor = Colors.white;
        timeColor = Colors.white.withValues(alpha: 0.6);
        checkReadColor = Colors.blue;
        checkUnreadColor = Colors.white.withValues(alpha: 0.6);
      } else {
        backgroundColor = const Color(0xFF6C9ECA);
        textColor = Colors.white;
        timeColor = Colors.white.withValues(alpha: 0.6);
        checkReadColor = Colors.white;
        checkUnreadColor = Colors.white.withValues(alpha: 0.6);
      }
    } else {
      if (isDark) {
        backgroundColor = const Color(0xFF2B2D31);
        textColor = Colors.white;
        timeColor = Colors.white.withValues(alpha: 0.6);
      } else {
        backgroundColor = const Color(0xFFF2F2F7);
        textColor = Colors.black;
        timeColor = Colors.grey;
      }
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: timeColor,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.read ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.read ? checkReadColor : checkUnreadColor,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
