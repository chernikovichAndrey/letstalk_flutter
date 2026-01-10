part of 'chat_details_bloc.dart';

enum ChatDetailsStatus { initial, loading, success, failure }

class ChatDetailsState {
  final ChatDetailsStatus status;
  final List<Message> messages;
  final bool hasReachedMax;
  final String? errorMessage;

  const ChatDetailsState({
    this.status = ChatDetailsStatus.initial,
    this.messages = const [],
    this.hasReachedMax = false,
    this.errorMessage,
  });

  ChatDetailsState copyWith({
    ChatDetailsStatus? status,
    List<Message>? messages,
    bool? hasReachedMax,
    String? errorMessage,
  }) {
    return ChatDetailsState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage,
    );
  }
}
