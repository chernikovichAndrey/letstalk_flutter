part of 'chats_bloc.dart';

enum RemoveType {
  all,
  me,
}

abstract class ChatsEvent {}

class ChatsLoad extends ChatsEvent {}

class ResetChatsBloc extends ChatsEvent {}

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
  final int? unreadCount;
  final int? lastMessageId;
  final String? lastMessageText;
  final String? lastMessageType;
  final String? lastMessageAt;

  ChatUpdated({
    required this.chatId,
    this.unreadCount,
    this.lastMessageId,
    this.lastMessageText,
    this.lastMessageType,
    this.lastMessageAt,
  });
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

class RemoveChat extends ChatsEvent {
  final int chatId;
  final RemoveType type;

  RemoveChat({required this.chatId, required this.type});
}

class ChatMemberRemoved extends ChatsEvent {
  final int chatId;

  ChatMemberRemoved(this.chatId);
}

class CreateChatGroup extends ChatsEvent {
  final List<int> userIds;
  final String title;
  final String? avatar;

  CreateChatGroup(this.userIds, this.title, this.avatar);
}

class MuteChat extends ChatsEvent {
  final int chatId;
  final bool muted;

  MuteChat({required this.chatId, required this.muted});
}