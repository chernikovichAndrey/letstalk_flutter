import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';

class MessageBubbleInfo extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubbleInfo({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    Color timeColor;
    Color? checkReadColor;
    Color? checkUnreadColor;
    if (isMe) {
      timeColor = appColors.messageMeTime;
      checkReadColor = appColors.messageReadIcon;
      checkUnreadColor = appColors.messageMeTime;
    } else {
      timeColor = appColors.messageOtherTime;
    }
    final timeFormat = DateFormat('HH:mm');
    final DateTime? createdAt = DateTime.tryParse(message.createdAt);
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
        if (isMe) ...[
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
