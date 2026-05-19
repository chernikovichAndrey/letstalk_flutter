import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
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
      useSafeArea: true,
      builder: (context) {
        final state = getIt<ChatsBloc>().state as ChatsLoaded;
        final selectedChats = filterChatsByIds(state.chats, state.selectedChatIds);
        final onlyGroupChats = selectedChats.every((chat) => chat.type == 'group');

        return Container(
          color: Colors.transparent,
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: 16.0 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!onlyGroupChats)
                ...[
                  ChatAppBarActionButton(
                    label: selectedChats.length > 1 ? context.s.deleteForEveryoneWherePossible : context.s.deleteForBothParticipants,
                    onPress: () {
                      context.pop();
                      for (final chatId in state.selectedChatIds) {
                        getIt<ChatsBloc>().add(RemoveChat(chatId: chatId, type: RemoveType.all));
                      }
                    },
                  ),
                  SizedBox(height: 4),
                ],
              ChatAppBarActionButton(
                label: onlyGroupChats ? context.s.deleteChats(selectedChats.length) : context.s.deleteForMe,
                onPress: () {
                  context.pop();
                  for (final chatId in state.selectedChatIds) {
                    getIt<ChatsBloc>().add(RemoveChat(chatId: chatId, type: RemoveType.me));
                  }
                },
              ),
              SizedBox(height: 4),
              ChatAppBarActionButton(
                label: context.s.cancel,
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
