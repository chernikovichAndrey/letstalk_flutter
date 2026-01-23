part of 'chats_bloc.dart';

abstract class ChatsState {}

class ChatsInitial extends ChatsState {}

class ChatsLoading extends ChatsState {}

class ChatsLoaded extends ChatsState {
  final List<Chat> chats;
  final Map<int, Set<int>> typingUsers;
  final bool isSelectionMode;
  final Set<int> selectedChatIds;

  ChatsLoaded(
    this.chats, {
    this.typingUsers = const {},
    this.isSelectionMode = false,
    this.selectedChatIds = const {},
  });
}

class ChatsError extends ChatsState {
  final String message;

  ChatsError(this.message);
}
