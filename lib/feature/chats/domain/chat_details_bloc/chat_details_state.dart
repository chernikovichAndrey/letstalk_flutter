part of 'chat_details_bloc.dart';

enum ChatDetailsStatus { initial, loading, success, failure }

class ChatDetailsState {
  final ChatDetailsStatus status;
  final List<Message> messages;
  final bool hasReachedMax;
  final String? errorMessage;
  final int? currentUserId;
  final Chat? chat;
  final List<ChatMember> members;

  const ChatDetailsState({
    this.status = ChatDetailsStatus.initial,
    this.messages = const [],
    this.hasReachedMax = false,
    this.errorMessage,
    this.currentUserId,
    this.chat,
    this.members = const [],
  });

  ChatDetailsState copyWith({
    ChatDetailsStatus? status,
    List<Message>? messages,
    bool? hasReachedMax,
    String? errorMessage,
    int? currentUserId,
    Chat? chat,
    List<ChatMember>? members,
  }) {
    return ChatDetailsState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage,
      currentUserId: currentUserId ?? this.currentUserId,
      chat: chat ?? this.chat,
      members: members ?? this.members,
    );
  }
}
