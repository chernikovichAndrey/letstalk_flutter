import 'package:flutter/material.dart';
import 'package:lets_talk/app/router/arg/MemberInfoArgs.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/extension/list_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/view/sheet/message_actions_overlay.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/message_bubble_info.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/message_forward.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/message_image_attach_thumbnail.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/message_document_attach.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/message_reply.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool isGroupChat;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.isGroupChat = false,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    Color backgroundColor = isMe
        ? appColors.messageMeBubble
        : appColors.messageOtherBubble;

    final shouldShowAvatar = isGroupChat && !isMe;
    final senderInfo = message.fromName?.isNotEmpty == true
        ? message.fromName!.first
        : null;

    final messageBubble = GestureDetector(
      onLongPress: () => MessageActionsOverlay.show(
        context,
        message,
        isMe,
        isGroupChat: isGroupChat,
      ),
      child: Container(
        margin: EdgeInsets.only(
          left: shouldShowAvatar ? 8 : 16,
          right: 16,
          top: 4,
          bottom: 4,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(maxWidth: context.mediaSize.width * 0.75),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe
                ? const Radius.circular(12)
                : const Radius.circular(4),
            bottomRight: isMe
                ? const Radius.circular(4)
                : const Radius.circular(12),
          ),
        ),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (message.replyTo != null)
                  MessageReplay(replyTo: message.replyTo!, isMe: isMe),
                if (message.messageType == 'image' &&
                    message.media?.thumbnailUrl != null)
                  MessageImageAttachThumbnail(
                    thumbnailUrl: message.media!.thumbnailUrl!,
                    messageId: message.id,
                    message: message,
                  ),
                if (message.messageType == 'document')
                  MessageDocumentAttach(message: message, isMe: isMe),

                if (message.messageType == 'text')
                  MessageForward(forwardedFrom: message.forwardedFrom),

                Text(
                  message.text ?? '',
                  style: context.text.bodyMedium?.copyWith(
                    color: isMe
                        ? Colors.white
                        : context.appColors.messageOtherText,
                  ),
                ),
                MessageBubbleInfo(message: message, isMe: isMe),
              ],
            ),
          ],
        ),
      ),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: shouldShowAvatar
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: GestureDetector(
                    onTap: () {
                      final chat = getIt<ChatDetailsBloc>().state.chat;
                      final memberInfo = chat?.memberInfo?.firstWhereOrNull(
                        (member) => member.id == message.fromUserId,
                      );
                      if (memberInfo != null) {
                        context.push(
                          Routes.memberInfoSheet,
                          args: MemberInfoArgs(memberInfo: memberInfo),
                        );
                      }
                    },
                    child: CAvatar(
                      imageUrl: senderInfo?.avatarUrl,
                      name: senderInfo?.fullName ?? senderInfo?.firstName,
                      radius: 20,
                    ),
                  ),
                ),
                Flexible(child: messageBubble),
              ],
            )
          : messageBubble,
    );
  }
}
