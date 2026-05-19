import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';

class EditPreview extends StatelessWidget {
  final Message message;

  const EditPreview({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final content = (message.text != null && message.text!.isNotEmpty)
        ? message.text!
        : message.messageType;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: IntrinsicHeight(
        child: Row(
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.s.editMessage,
                    style: context.text.bodyMedium?.copyWith(
                      color: AppColors.brand,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.appColors.glassForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                context.read<ChatDetailsBloc>().add(
                  ChatDetailsSetEditingMessage(null),
                );
              },
              child: Icon(
                Icons.close,
                size: 24,
                color: context.appColors.glassForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
