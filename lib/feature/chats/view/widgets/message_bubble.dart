import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/view/widgets/message_actions_overlay.dart';

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
    final appColors = context.appColors;
    
    final timeFormat = DateFormat('HH:mm');
    final DateTime? createdAt = DateTime.tryParse(message.createdAt);
    final String time = createdAt != null ? timeFormat.format(createdAt.toLocal()) : '';

    Color backgroundColor;
    Color textColor;
    Color timeColor;
    Color? checkReadColor;
    Color? checkUnreadColor;

    if (isMe) {
      backgroundColor = appColors.messageMeBubble;
      textColor = appColors.messageMeText;
      timeColor = appColors.messageMeTime;
      checkReadColor = appColors.messageReadIcon;
      checkUnreadColor = appColors.messageMeTime;
    } else {
      backgroundColor = appColors.messageOtherBubble;
      textColor = appColors.messageOtherText;
      timeColor = appColors.messageOtherTime;
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => MessageActionsOverlay.show(context, message, isMe),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(4),
              bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(12),
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 8,
            children: [
              Text(
                message.text ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: theme.textTheme.labelSmall?.copyWith(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
