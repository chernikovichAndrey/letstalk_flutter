part of 'chat_details_bloc.dart';

abstract class ChatDetailsEvent {}

class ChatDetailsLoad extends ChatDetailsEvent {
  final int chatId;
  ChatDetailsLoad(this.chatId);
}

class ChatDetailsLoadMore extends ChatDetailsEvent {
  final int chatId;
  ChatDetailsLoadMore(this.chatId);
}
