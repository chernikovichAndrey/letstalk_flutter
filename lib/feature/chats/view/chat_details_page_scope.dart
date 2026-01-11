import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/feature/chats/data/repository/chats_repository_impl.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/view/chat_details_page.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

class ChatDetailsPageScope extends StatelessWidget {
  final int chatId;
  final String chatTitle;

  const ChatDetailsPageScope({
    super.key,
    required this.chatId,
    required this.chatTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (cx, state) {
        if (state is ProfileLoaded) {
          return BlocProvider(
            create: (context) =>
            ChatDetailsBloc(ChatsRepositoryImpl())
              ..add(ChatDetailsLoad(chatId, state.user)),
            child: ChatDetailsPage(chatId: chatId, chatTitle: chatTitle),
          );
        }
        return Container();
      },
    );
  }
}
