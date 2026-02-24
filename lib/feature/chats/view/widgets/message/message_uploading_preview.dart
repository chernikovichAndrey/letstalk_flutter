import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';

class MessageUploadingPreview extends StatelessWidget {
  final Message message;

  const MessageUploadingPreview({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
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

}