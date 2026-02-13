import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';

class MessageReplay extends StatelessWidget {
  final ReplyTo replyTo;
  final bool isMe;

  const MessageReplay({super.key,
    required this.replyTo,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final token = (context.read<AuthBloc>().state as AuthAuthenticated).token;

    final appColors = context.appColors;
    Color textColor = isMe ? appColors.messageMeText : appColors.messageOtherText;

    return BlocBuilder<ChatDetailsBloc, ChatDetailsState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isMe
                ? Colors.black.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border(
              left: BorderSide(
                color: Colors.white,
                width: 4,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (replyTo.media != null && replyTo.media?.thumbnailUrl != null)
                ...[
                  Image.network(
                    replyTo.media!.thumbnailUrl!,
                    headers: {'Authorization': 'Bearer $token'},
                    height: 40,
                    width: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image, color: Colors.white70, size: 20),
                  ),
                  SizedBox(width: 6.0),
                ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      replyTo.fromName?.firstOrNull?.fullName ?? 
                      replyTo.fromName?.firstOrNull?.firstName ?? '',
                      style: context.text.labelMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      replyTo.textPreview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}