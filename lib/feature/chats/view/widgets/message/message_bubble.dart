import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lets_talk/app/router/arg/MemberInfoArgs.dart';
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
import 'package:lets_talk/feature/chats/view/widgets/message/message_video_attach_thumbnail.dart';
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

  Widget _buildUploadingPreview(Message message, BuildContext context) {
    final isImage = message.messageType == 'image';
    final isVideo = message.messageType == 'video';
    final progress = message.uploadProgress ?? 0.0;
    final progressPercent = (progress * 100).toInt();
    
    if ((isImage || isVideo) && message.localFilePath != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(message.localFilePath!),
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 200,
                height: 200,
                color: Colors.grey[800],
                child: Icon(
                  isVideo ? Icons.videocam : Icons.image,
                  color: Colors.white70,
                  size: 48,
                ),
              ),
            ),
          ),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                        value: progress > 0 ? progress : null,
                      ),
                    ),
                    if (progressPercent > 0)
                      Text(
                        '$progressPercent%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  context.s.uploading,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    
    // For documents and audio show filename with loading indicator
    if ((message.messageType == 'document' || message.messageType == 'audio') && 
        message.localFilePath != null) {
      final filename = message.localFilePath!.split('/').last;
      final icon = message.messageType == 'audio' ? Icons.audiotrack : Icons.insert_drive_file;
      final progress = message.uploadProgress ?? 0.0;
      final progressPercent = (progress * 100).toInt();
      
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 24),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    filename,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: progress > 0 ? progress : null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        progressPercent > 0 
                            ? '${context.s.uploading} $progressPercent%'
                            : context.s.uploading,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    // Fallback
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

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
      onTap: () => {
        if (message.messageType != 'document' && message.messageType != 'text') {
          context.push(
            Routes.mediaViewer,
            args: MediaViewerArgs(
              mediaUrl: message.media!.downloadUrl,
              mediaType: message.messageType,
              thumbnailUrl: message.media!.thumbnailUrl,
            ),
          )
        }
      },
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
                if (message.isUploading && message.localFilePath != null)
                  _buildUploadingPreview(message, context)
                else if (message.isUploading)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else ...[
                  if (message.messageType == 'image' &&
                      message.media?.thumbnailUrl != null)
                    MessageImageAttachThumbnail(
                      thumbnailUrl: message.media!.thumbnailUrl!,
                      messageId: message.id,
                      message: message,
                    ),
                  if (message.messageType == 'video' &&
                      message.media?.thumbnailUrl != null)
                    MessageVideoAttachThumbnail(
                      thumbnailUrl: message.media!.thumbnailUrl!,
                      messageId: message.id,
                      message: message,
                    ),
                  if (message.messageType == 'document')
                    MessageDocumentAttach(message: message, isMe: isMe),
                ],

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
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
