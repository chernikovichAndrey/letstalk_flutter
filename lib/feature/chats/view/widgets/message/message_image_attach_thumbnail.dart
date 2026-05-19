import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:lets_talk/feature/chats/data/model/media_model.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/message_forward.dart';

class MessageImageAttachThumbnail extends StatelessWidget {
  final Media media;
  final int messageId;
  final Message message;

  const MessageImageAttachThumbnail({
    super.key,
    required this.media,
    required this.messageId,
    required this.message,
  });

  static const double _maxWidth = 200;
  static const double _maxHeight = 300;

  Size _calculateSize() {
    final w = media.width;
    final h = media.height;
    if (w == null || h == null || w == 0 || h == 0) {
      return const Size(_maxWidth, _maxWidth);
    }
    final aspectRatio = w / h;
    double width = w.toDouble();
    double height = h.toDouble();
    if (width > _maxWidth) {
      width = _maxWidth;
      height = width / aspectRatio;
    }
    if (height > _maxHeight) {
      height = _maxHeight;
      width = height * aspectRatio;
    }
    return Size(width, height);
  }

  @override
  Widget build(BuildContext context) {
    final token = (context.read<AuthBloc>().state as AuthAuthenticated).token;
    final size = _calculateSize();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MessageForward(forwardedFrom: message.forwardedFrom),
        Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                media.thumbnailUrl!,
                headers: {'Authorization': 'Bearer $token'},
                width: size.width,
                height: size.height,
                fit: BoxFit.fitHeight,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image, color: Colors.white70, size: 20),
              ),
            ),
            BlocBuilder<ChatDetailsBloc, ChatDetailsState>(
              builder: (context, state) {
                if (state.downloadingMessageId == messageId) {
                  final progress = state.downloadProgress ?? 0.0;
                  final progressPercent = (progress * 100).toInt();

                  return Container(
                    width: size.width,
                    height: size.height,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
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
      ],
    );
  }
}
