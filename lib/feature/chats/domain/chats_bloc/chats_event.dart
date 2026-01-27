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
  final Message? message;

  ChatUpdated(this.chatId, [this.message]);
}

class ChatTypingUpdated extends ChatsEvent {
  final int chatId;
  final int userId;
  final bool isTyping;

  ChatTypingUpdated({
    required this.chatId,
    required this.userId,
    required this.isTyping,
  });
}

class ChatsToggleSelectionMode extends ChatsEvent {}

class ChatsToggleChatSelection extends ChatsEvent {
  final int chatId;

  ChatsToggleChatSelection(this.chatId);
}

class ChatsDeleteSelected extends ChatsEvent {}

class RemoveChat extends ChatsEvent {
  final int chatId;
  final List<int> userIds;

  RemoveChat({required this.chatId, required this.userIds});
}
