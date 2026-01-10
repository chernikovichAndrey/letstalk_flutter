part of 'chats_bloc.dart';

abstract class ChatsEvent {}

class ChatsLoad extends ChatsEvent {}

class ChatsRefresh extends ChatsEvent {
  final Completer? completer;

  ChatsRefresh([this.completer]);
}

class ChatsSearch extends ChatsEvent {
  final String query;

  ChatsSearch(this.query);
}

class ChatUpdated extends ChatsEvent {
  final int chatId;

  ChatUpdated(this.chatId);
}
