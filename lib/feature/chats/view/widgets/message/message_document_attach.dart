import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/l10n/generated/l10n.dart';
import 'package:lets_talk/common/widget/toasts.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:path_provider/path_provider.dart';

class MessageDocumentAttach extends StatefulWidget {
  final Message message;
  final bool isMe;

  const MessageDocumentAttach({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  State<MessageDocumentAttach> createState() => _MessageDocumentAttachState();
}

class _MessageDocumentAttachState extends State<MessageDocumentAttach> {
  Future<void> _downloadAndOpen() async {
    final media = widget.message.media;
    if (media == null) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/${media.filename}';

      if (!mounted) return;

      context.read<ChatDetailsBloc>().add(
            DownloadDocument(
              mediaUrl: media.downloadUrl,
              savePath: savePath,
              messageId: widget.message.id,
            ),
          );
    } catch (e) {
      if (!mounted) return;
      showErrorToast(
        context.s.downloadError(e.toString())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.message.media;
    if (media == null) {
      return const SizedBox.shrink();
    }

    final appColors = context.appColors;
    final textColor = widget.isMe ? appColors.messageMeText : appColors.messageOtherText;
    final iconBgColor = widget.isMe ? Colors.white.withOpacity(0.2) : appColors.telegramBlue.withOpacity(0.1);
    final iconColor = widget.isMe ? Colors.white : appColors.telegramBlue;

    return BlocBuilder<ChatDetailsBloc, ChatDetailsState>(
      builder: (context, state) {
        final isDownloading = state.downloadingMessageId == widget.message.id;
        final progress = isDownloading ? state.downloadProgress : null;

        return GestureDetector(
          onTap: isDownloading ? null : _downloadAndOpen,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isDownloading
                    ? Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 2,
                          color: iconColor,
                        ),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.insert_drive_file,
                            color: iconColor,
                            size: 38,
                          ),
                          Icon(
                            Icons.download,
                            color: Colors.black.withValues(alpha: 0.5),
                            size: 20,
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      media.filename,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatBytes(media.size, 1),
                      style: context.text.bodySmall?.copyWith(
                        color: textColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
