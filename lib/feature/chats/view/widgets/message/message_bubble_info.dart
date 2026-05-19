import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';

class MessageBubbleInfo extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool isFavoritesChat;

  const MessageBubbleInfo({
    super.key,
    required this.message,
    required this.isMe,
    required this.isFavoritesChat,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final Color timeColor;
    Color? checkReadColor;
    Color? checkUnreadColor;
    if (isMe) {
      checkReadColor = appColors.messageReadIcon;
      checkUnreadColor = appColors.messageMeTime;
      timeColor = message.read ? checkReadColor : checkUnreadColor;
    } else {
      timeColor = appColors.messageOtherTime;
    }
    final timeFormat = DateFormat('HH:mm');
    final DateTime? createdAt = DateTime.tryParse('${message.createdAt}Z');
    final String time = createdAt != null
        ? timeFormat.format(createdAt.toLocal())
        : '';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.isEdited) ...[
          Text(
            context.s.edited,
            style: context.text.labelSmall?.copyWith(
              color: timeColor,
              fontSize: 9,
            ),
          ),
          const SizedBox(width: 4),
        ],
        Text(
          time,
          style: context.text.labelSmall?.copyWith(
            color: timeColor,
            fontSize: 9,
          ),
        ),
        if (isMe && !isFavoritesChat) ...[
          const SizedBox(width: 4),
          Icon(
            message.read ? Icons.done_all : Icons.done,
            size: 14,
            color: message.read ? checkReadColor : checkUnreadColor,
          ),
        ],
      ],
    );
  }
}
