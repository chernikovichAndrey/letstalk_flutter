import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/extension/list_ext.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

class ReplayPreview extends StatelessWidget {
  final Message message;

  const ReplayPreview({super.key, required this.message});

  String _memberName() {
    final myId = getIt<ProfileBloc>().state.user?.id;
    final state = getIt<ChatDetailsBloc>().state;
    final member = state.chat?.memberInfo?.firstWhereOrNull((member) => member.id != myId);
    return member?.fullName ?? member?.firstName ?? '';
  }

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
                  context.s.replyingTo(_memberName()),
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
                ChatDetailsReplyToMessage(null),
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