import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/feature/chats/data/repository/chats_repository_impl.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/view/chat_details_page.dart';

class ChatDetailsPageScope extends StatelessWidget {
  final int chatId;

  const ChatDetailsPageScope({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatDetailsBloc(ChatsRepositoryImpl())..add(ChatDetailsLoad(chatId)),
      child: ChatDetailsPage(chatId: chatId),
    );
  }
}
