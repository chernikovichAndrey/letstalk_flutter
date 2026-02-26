import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/extension/list_ext.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/call/domain/bloc/call_bloc.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/domain/chats_bloc/chats_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_info/chat_info_action_button.dart';

class ChatInfoActionsGroup extends StatelessWidget {
  final MemberInfo member;
  final bool isGroupChat;

  const ChatInfoActionsGroup({
    super.key,
    required this.member,
    this.isGroupChat = false,
  });

  @override
  Widget build(BuildContext context) {
    final chatId = getIt<ChatDetailsBloc>().state.chat!.id;


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
                CallInitiated(
                  targetUserId: member.id,
                  avatar: member.avatar,
                  fullName: member.fullName,
                ),
              );
            },
          ),
        if (!isGroupChat)
          ChatInfoActionButton(
            context: context,
            icon: Icons.videocam,
            label: context.s.videoCallAction,
            onTap: () {
              getIt<CallBloc>().add(
                CallInitiated(
                  targetUserId: member.id,
                  avatar: member.avatar,
                  fullName: member.fullName,
                  isVideo: true,
                ),
              );
            },
          ),
        BlocBuilder<ChatsBloc, ChatsState>(
          builder: (context, state) {
            if (state is ChatsLoaded) {
              final isMuted = state.chats.firstWhereOrNull((chat) => chat.id == chatId)?.muted ?? false;
              return ChatInfoActionButton(
                context: context,
                icon: isMuted
                    ? Icons.notifications_off
                    : Icons.notifications,
                label: context.s.sound,
                onTap: () {
                  getIt<ChatsBloc>().add(
                    MuteChat(
                      chatId: chatId,
                      muted: !isMuted,
                    ),
                  );
                },
              );
            }
            return const SizedBox();
          }
        ),
        // if (isGroupChat) SizedBox(width: 12),
        // ChatInfoActionButton(
        //   context: context,
        //   icon: Icons.more_horiz,
        //   label: context.s.more,
        //   onTap: () {
        //     //TODO
        //     showWarningToast(context.s.notWorkingNow);
        //   },
        // ),
      ],
    );
  }
}
