part of 'chat_details_bloc.dart';

abstract class ChatDetailsEvent {}

class ChatDetailsLoad extends ChatDetailsEvent {
  final int chatId;
  final UserModel user;
  ChatDetailsLoad(this.chatId, this.user);
}

class ChatDetailsLoadMore extends ChatDetailsEvent {
  final int chatId;
  ChatDetailsLoadMore(this.chatId);
}

class ChatDetailsSendMessage extends ChatDetailsEvent {
  final String text;
  ChatDetailsSendMessage(this.text);
}

class ChatDetailsSendTyping extends ChatDetailsEvent {
  final bool isTyping;
  ChatDetailsSendTyping(this.isTyping);
}

class ChatDetailsNewMessageReceived extends ChatDetailsEvent {
  final Message message;
  ChatDetailsNewMessageReceived(this.message);
}

class ChatDetailsErrorReceived extends ChatDetailsEvent {
  final String error;
  ChatDetailsErrorReceived(this.error);
}
