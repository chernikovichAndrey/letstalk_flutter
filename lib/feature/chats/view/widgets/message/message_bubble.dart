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
          constraints: BoxConstraints(maxWidth: context.mediaSize.width * 0.75),
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
                  if (message.replyTo != null)
                    _ReplyMessageWidget(
                      replyTo: message.replyTo!,
                      isMe: isMe,
                    ),
                  if (message.messageType == 'image' && message.media?.thumbnailUrl != null)
                    MessageImageAttachThumbnail(
                      thumbnailUrl: message.media!.thumbnailUrl!,
                      messageId: message.id,
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

class _ReplyMessageWidget extends StatelessWidget {
  final ReplyTo replyTo;
  final bool isMe;

  const _ReplyMessageWidget({
    required this.replyTo,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.black.withOpacity(0.1)
            : Colors.black.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: Border(
          left: BorderSide(
            color: isMe ? Colors.white : context.color.primary,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            replyTo.fromName,
            style: context.text.labelMedium?.copyWith(
              color: isMe ? Colors.white : context.color.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            replyTo.textPreview,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodySmall?.copyWith(
              color: isMe
                  ? Colors.white.withOpacity(0.8)
                  : Colors.black.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
