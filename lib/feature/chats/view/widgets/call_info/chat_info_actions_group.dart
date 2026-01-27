import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/toasts.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/call/domain/bloc/call_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/call_info/chat_info_action_button.dart';

class ChatInfoActionsGroup extends StatelessWidget {
  final int targetUserId;

  const ChatInfoActionsGroup({super.key, required this.targetUserId});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ChatInfoActionButton(
          context: context,
          icon: Icons.phone,
          label: 'звонок',
          onTap: () {
            getIt<CallBloc>().add(CallInitiated(targetUserId: targetUserId));
          },
        ),
        ChatInfoActionButton(
          context: context,
          icon: Icons.videocam,
          label: 'видео',
          onTap: () {
            getIt<CallBloc>().add(
              CallInitiated(targetUserId: targetUserId, isVideo: true),
            );
          },
        ),
        ChatInfoActionButton(
          context: context,
          icon: Icons.notifications,
          label: 'звук',
          onTap: () {
            //TODO
            showWarningToast(context.s.notWorkingNow);
          },
        ),
        ChatInfoActionButton(
          context: context,
          icon: Icons.more_horiz,
          label: 'ещё',
          onTap: () {
            //TODO
            showWarningToast(context.s.notWorkingNow);
          },
        ),
      ],
    );
  }
}
