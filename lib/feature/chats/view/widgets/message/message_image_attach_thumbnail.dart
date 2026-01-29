import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/message_forward.dart';

class MessageImageAttachThumbnail extends StatelessWidget {
  final String thumbnailUrl;
  final int messageId;
  final Message message;

  const MessageImageAttachThumbnail({
    super.key,
    required this.thumbnailUrl,
    required this.messageId,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final token = (context.read<AuthBloc>().state as AuthAuthenticated).token;
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
                thumbnailUrl,
                headers: {'Authorization': 'Bearer $token'},
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image, color: Colors.white70, size: 20),
              ),
            ),
            BlocBuilder<ChatDetailsBloc, ChatDetailsState>(
              builder: (context, state) {
                if (state.downloadingMessageId == messageId) {
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: state.downloadProgress,
                        color: Colors.white,
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
