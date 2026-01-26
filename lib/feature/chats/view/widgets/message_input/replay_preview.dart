import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    final myId = (getIt<ProfileBloc>().state as ProfileLoaded).user.id;
    final state = getIt<ChatDetailsBloc>().state;
    final member = state.chat?.memberInfo?.firstWhereOrNull((member) => member.id != myId);
    return member?.fullName ?? member?.firstName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final content = (message.text != null && message.text!.isNotEmpty)
        ? message.text!
        : message.messageType;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.appColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: context.appColors.telegramBlue,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.s.replyingTo(_memberName()),
                  style: TextStyle(
                    color: context.appColors.telegramBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  content,
                  style: context.theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 20),
            onPressed: () {
              context.read<ChatDetailsBloc>().add(
                ChatDetailsReplyToMessage(null),
              );
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

}