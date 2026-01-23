import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';

class MessageDocumentAttach extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageDocumentAttach({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final media = message.media;
    if (media == null) {
      return const SizedBox.shrink();
    }

    final appColors = context.appColors;
    final textColor = isMe ? appColors.messageMeText : appColors.messageOtherText;
    final iconBgColor = isMe ? Colors.white.withOpacity(0.2) : appColors.telegramBlue.withOpacity(0.1);
    final iconColor = isMe ? Colors.white : appColors.telegramBlue;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.insert_drive_file,
            color: iconColor,
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
    );
  }

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
