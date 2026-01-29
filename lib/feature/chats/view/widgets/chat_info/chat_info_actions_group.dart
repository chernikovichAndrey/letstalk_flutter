import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/toasts.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/call/domain/bloc/call_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_info/chat_info_action_button.dart';

class ChatInfoActionsGroup extends StatelessWidget {
  final int targetUserId;
  final bool isGroupChat;

  const ChatInfoActionsGroup({
    super.key,
    required this.targetUserId,
    this.isGroupChat = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isGroupChat
          ? MainAxisAlignment.center
          : MainAxisAlignment.spaceEvenly,
      children: [
        if (!isGroupChat)
          ChatInfoActionButton(
            context: context,
            icon: Icons.phone,
            label: context.s.call,
            onTap: () {
              getIt<CallBloc>().add(
                  CallInitiated(targetUserId: targetUserId));
            },
          ),
        if (!isGroupChat)
          ChatInfoActionButton(
            context: context,
            icon: Icons.videocam,
            label: context.s.videoCallAction,
            onTap: () {
              getIt<CallBloc>().add(
                CallInitiated(targetUserId: targetUserId, isVideo: true),
              );
            },
          ),
        ChatInfoActionButton(
          context: context,
          icon: Icons.notifications,
          label: context.s.sound,
          onTap: () {
            //TODO
            showWarningToast(context.s.notWorkingNow);
          },
        ),
        if(isGroupChat)
          SizedBox(width: 12,),
        ChatInfoActionButton(
          context: context,
          icon: Icons.more_horiz,
          label: context.s.more,
          onTap: () {
            //TODO
            showWarningToast(context.s.notWorkingNow);
          },
        ),
      ],
    );
  }
}
