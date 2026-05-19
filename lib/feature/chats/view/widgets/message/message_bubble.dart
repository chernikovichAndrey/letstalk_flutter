import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lets_talk/app/router/arg/member_info_args.dart';
import 'package:lets_talk/app/router/arg/media_viewer_args.dart';
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
import 'package:lets_talk/feature/chats/view/widgets/message/message_uploading_preview.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/message_video_attach_thumbnail.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/message_document_attach.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/message_reply.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool isGroupChat;
  final bool isFavoritesChat;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.isFavoritesChat,
    this.isGroupChat = false,
  });

  static const double _outerRadius = 20;
  static const double _tailRadius = 4;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final Color backgroundColor = isMe
        ? appColors.messageMeBubble
        : appColors.messageOtherBubble;

    final shouldShowAvatar = isGroupChat && !isMe;
    final senderInfo = message.fromName?.isNotEmpty == true
        ? message.fromName!.first
        : null;

    final bool hasMedia = !message.isUploading && (
      (message.messageType == 'image' && message.media?.thumbnailUrl != null) ||
      (message.messageType == 'video' && message.media != null)
    );
    final bool hasText = message.text?.isNotEmpty == true;
    final bool isMediaOnly = hasMedia && !hasText;

    // Tight layout: image/video flush with bubble edges (1px gap), no reply/forward above
    final bool useTightLayout = hasMedia &&
        message.forwardedFrom == null &&
        message.replyTo == null;

    final BorderRadius bubbleRadius = isMediaOnly && useTightLayout
        ? BorderRadius.circular(_outerRadius)
        : BorderRadius.only(
            topLeft: const Radius.circular(_outerRadius),
            topRight: const Radius.circular(_outerRadius),
            bottomLeft: isMe
                ? const Radius.circular(_outerRadius)
                : const Radius.circular(_tailRadius),
            bottomRight: isMe
                ? const Radius.circular(_tailRadius)
                : const Radius.circular(_outerRadius),
          );

    // Border radius for the media content itself (slightly inset from bubble)
    final BorderRadius mediaRadius = isMediaOnly
        ? BorderRadius.circular(_outerRadius)
        : const BorderRadius.only(
            topLeft: Radius.circular(_outerRadius),
            topRight: Radius.circular(_outerRadius),
          );

    final EdgeInsets bubblePadding = useTightLayout
        ? (hasText
            ? const EdgeInsets.fromLTRB(1, 1, 1, 8)
            : const EdgeInsets.all(1))
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

    Widget buildInfo({bool onImage = false}) => MessageBubbleInfo(
          message: message,
          isMe: isMe,
          isFavoritesChat: isFavoritesChat,
          onImage: onImage,
        );

    Widget buildTextSection() => Stack(
          alignment: Alignment.bottomRight,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.messageType == 'text')
                  MessageForward(
                      forwardedFrom: message.forwardedFrom, isMe: isMe),
                Text.rich(
                  TextSpan(
                    style: context.text.bodyMedium?.copyWith(
                      color: isMe
                          ? appColors.messageMeText
                          : appColors.messageOtherText,
                    ),
                    children: [
                      TextSpan(
                        text: message.text ?? '',
                        style: context.text.bodyMedium?.copyWith(
                          letterSpacing: 0,
                          height: 1,
                          color: isMe
                              ? appColors.messageMeText
                              : appColors.messageOtherText,
                        ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.bottom,
                        child: Opacity(
                          opacity: 0,
                          child: Padding(
                            padding: Platform.isIOS
                                ? const EdgeInsets.only(left: 8, top: 2)
                                : const EdgeInsets.only(left: 5),
                            child: buildInfo(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            buildInfo(),
          ],
        );

    Widget buildContent() {
      if (message.isUploading) {
        if (message.localFilePath != null) {
          return MessageUploadingPreview(message: message);
        }
        return Container(
          padding: const EdgeInsets.all(16),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      }

      if (useTightLayout) {
        final Widget mediaWidget = message.messageType == 'image'
            ? MessageImageAttachThumbnail(
                media: message.media!,
                messageId: message.id,
                message: message,
                isMe: isMe,
                borderRadius: mediaRadius,
              )
            : MessageVideoAttachThumbnail(
                messageId: message.id,
                message: message,
                isMe: isMe,
                borderRadius: mediaRadius,
              );

        if (isMediaOnly) {
          return Stack(
            alignment: Alignment.bottomRight,
            children: [
              mediaWidget,
              Padding(
                padding: const EdgeInsets.only(bottom: 8, right: 8),
                child: buildInfo(onImage: true),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            mediaWidget,
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: buildTextSection(),
            ),
          ],
        );
      }

      return Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.messageType == 'image' &&
              message.media?.thumbnailUrl != null)
            MessageImageAttachThumbnail(
              media: message.media!,
              messageId: message.id,
              message: message,
              isMe: isMe,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(_outerRadius),
                topRight: Radius.circular(_outerRadius),
              ),
            ),
          if (message.messageType == 'video' && message.media != null)
            MessageVideoAttachThumbnail(
              messageId: message.id,
              message: message,
              isMe: isMe,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(_outerRadius),
                topRight: Radius.circular(_outerRadius),
              ),
            ),
          if (message.messageType == 'document')
            MessageDocumentAttach(message: message, isMe: isMe),
          buildTextSection(),
        ],
      );
    }

    final messageBubble = GestureDetector(
      onLongPress: () => MessageActionsOverlay.show(
        context,
        message,
        isMe,
        isGroupChat: isGroupChat,
        isFavoritesChat: isFavoritesChat,
      ),
      onTap: () {
        if (message.messageType != 'document' &&
            message.messageType != 'text') {
          context.push(
            Routes.mediaViewer,
            args: MediaViewerArgs(
              videoUrl: message.media!.videoUrl!,
              mediaType: message.messageType,
              thumbnailUrl: message.media!.thumbnailUrl,
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(
          left: shouldShowAvatar ? 8 : 16,
          right: 16,
          top: 4,
          bottom: 4,
        ),
        constraints:
            BoxConstraints(maxWidth: context.mediaSize.width * 0.75),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: bubbleRadius,
        ),
        clipBehavior: Clip.antiAlias,
        padding: bubblePadding,
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.replyTo != null)
              MessageReplay(replyTo: message.replyTo!, isMe: isMe),
            buildContent(),
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
                      imageUrl: senderInfo?.avatar,
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
