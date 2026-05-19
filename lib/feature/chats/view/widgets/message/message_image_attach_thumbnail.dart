import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:lets_talk/feature/chats/data/model/media_model.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';

class MessageImageAttachThumbnail extends StatelessWidget {
  final Media media;
  final int messageId;
  final Message message;
  final bool isMe;
  final BorderRadius borderRadius;

  const MessageImageAttachThumbnail({
    super.key,
    required this.media,
    required this.messageId,
    required this.message,
    required this.borderRadius,
    this.isMe = false,
  });

  static const double _maxHeight = 400;

  double _calculateHeight(double availableWidth) {
    final w = media.width;
    final h = media.height;
    if (w == null || h == null || w == 0 || h == 0) {
      return availableWidth;
    }
    final height = availableWidth / (w / h);
    return height.clamp(0, _maxHeight);
  }

  @override
  Widget build(BuildContext context) {
    final token = (context.read<AuthBloc>().state as AuthAuthenticated).token;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = _calculateHeight(width);
        return ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
          alignment: Alignment.center,
          children: [
            Image.network(
              media.thumbnailUrl!,
              headers: {'Authorization': 'Bearer $token'},
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => SizedBox(
                width: width,
                height: height,
                child: const Center(
                  child: Icon(Icons.image, color: Colors.white70, size: 32),
                ),
              ),
            ),
            BlocBuilder<ChatDetailsBloc, ChatDetailsState>(
              builder: (context, state) {
                if (state.downloadingMessageId == messageId) {
                  final progress = state.downloadProgress ?? 0.0;
                  final progressPercent = (progress * 100).toInt();
                  return Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 56,
                            height: 56,
                            child: CircularProgressIndicator(
                              value: state.downloadProgress,
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                          if (progressPercent > 0)
                            Text(
                              '$progressPercent%',
                              style: AppTypography.textSmRegular.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        );
      },
    );
  }
}
