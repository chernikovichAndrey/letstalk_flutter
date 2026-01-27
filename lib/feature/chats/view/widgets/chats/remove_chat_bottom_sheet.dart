import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/domain/chats_bloc/chats_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/chats/chat_app_bar_action_button.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

class RemoveChatBottomSheet {
  List<Chat> filterChatsByIds(List<Chat> chats, Set<int> ids) {
    return chats.where((chat) => ids.contains(chat.id)).toList();
  }

  RemoveChatBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appColors.secondaryBackground,
      builder: (context) {
        final myId = (getIt<ProfileBloc>().state as ProfileLoaded).user.id;
        final state = getIt<ChatsBloc>().state as ChatsLoaded;
        final selectedChats = filterChatsByIds(state.chats, state.selectedChatIds);
        final onlyGroupChats = selectedChats.every((chat) => chat.type == 'group');

        return Container(
          color: Colors.transparent,
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!onlyGroupChats)
                ...[
                  ChatAppBarActionButton(
                    label: selectedChats.length > 1 ? 'Удалить у всех где возможно' : 'Удалить у обоих участников',
                    onPress: () {
                      context.pop();
                      for (final chatId in state.selectedChatIds) {
                        final chat = state.chats.firstWhere((chat) => chat.id == chatId);
                        final chatMemberIds = chat.memberInfo?.map((e) => e.id).toList() ?? [];
                        getIt<ChatsBloc>().add(RemoveChat(chatId: chatId, userIds: chatMemberIds));
                      }
                    },
                  ),
                  SizedBox(height: 4),
                ],
              ChatAppBarActionButton(
                label: onlyGroupChats ? context.s.deleteChats(selectedChats.length) : 'Удалить у меня',
                onPress: () {
                  context.pop();
                  for (final chatId in state.selectedChatIds) {
                    getIt<ChatsBloc>().add(RemoveChat(chatId: chatId, userIds: [myId]));
                  }
                },
              ),
              SizedBox(height: 4),
              ChatAppBarActionButton(
                label: 'Отмена',
                isRead: false,
                onPress: context.pop,
              ),
            ],
          ),
        );
      },
    );
  }
}
