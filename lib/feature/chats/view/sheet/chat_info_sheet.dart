import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/extension/list_ext.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_info/chat_info_actions_group.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_info/chat_info_app_bar.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_info/chat_info_avatar.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_info/chat_info_chat_members.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_info/chat_info_user_info.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

class ChatInfoSheet extends StatelessWidget {
  const ChatInfoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.mediaSize.height * 0.92,
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: BlocProvider.value(
        value: getIt<ChatDetailsBloc>(),
        child: BlocBuilder<ChatDetailsBloc, ChatDetailsState>(
          builder: (context, state) {
            //TODO: add group style
            final isGroupChat = state.chat?.type == 'group';

            //this is for 1x1
            final member = state.chat?.memberInfo?.firstWhereOrNull((member) =>
              member.id != (getIt<ProfileBloc>().state as ProfileLoaded).user.id
            );

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        child: Column(
                          children: [
                            ChatInfoAvatar(),
                            SizedBox(height: 28,),
                            ChatInfoActionsGroup(targetUserId: member?.id ?? -1),
                            SizedBox(height: 28,),
                            if (isGroupChat)
                              ChatInfoChatMembers()
                            else
                              ChatInfoUserInfo(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const ChatInfoAppBar()
              ],
            );
          },
        ),
      ),
    );
  }
}
