import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/message_bubble_info.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/message_image_attach_thumbnail.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/message_actions_overlay.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/message_document_attach.dart';

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
    final appColors = context.appColors;

    Color backgroundColor = isMe ? appColors.messageMeBubble : appColors.messageOtherBubble;
    Color textColor = isMe ? appColors.messageMeText : appColors.messageOtherText;

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (message.messageType == 'image' && message.media?.thumbnailUrl != null)
                    MessageImageAttachThumbnail(
                      thumbnailUrl: message.media!.thumbnailUrl!,
                    ),
                  if (message.messageType == 'document')
                    MessageDocumentAttach(
                      message: message,
                      isMe: isMe,
                    ),

                  Text(
                    message.text ?? '',
                    style: context.text.bodyMedium?.copyWith(
                      color: textColor,
                    ),
                  ),
                  MessageBubbleInfo(
                    message: message,
                    isMe: isMe,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
