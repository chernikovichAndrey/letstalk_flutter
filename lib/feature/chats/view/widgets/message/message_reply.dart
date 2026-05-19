import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/utils/call_details_string_formatter.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';

class MessageReplay extends StatelessWidget {
  final ReplyTo replyTo;
  final bool isMe;

  const MessageReplay({super.key, required this.replyTo, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final token = (context.read<AuthBloc>().state as AuthAuthenticated).token;
    final textColor = isMe
        ? context.appColors.messageMeText
        : context.appColors.messageOtherText;

    return BlocBuilder<ChatDetailsBloc, ChatDetailsState>(
      builder: (context, state) {
        return IntrinsicWidth(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: AppColors.brand,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 8),
                if (replyTo.media != null &&
                    replyTo.media?.thumbnailUrl != null) ...[
                  Image.network(
                    replyTo.media!.thumbnailUrl!,
                    headers: {'Authorization': 'Bearer $token'},
                    height: 40,
                    width: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        replyTo.fromName?.firstOrNull?.fullName ??
                            replyTo.fromName?.firstOrNull?.firstName ??
                            '',
                        style: context.text.bodyMedium?.copyWith(
                          color: AppColors.brand,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (replyTo.media != null && replyTo.textPreview.isEmpty)
                            ? getMessageTypeText(context, replyTo.media!.type)
                            : replyTo.textPreview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyMedium?.copyWith(
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
