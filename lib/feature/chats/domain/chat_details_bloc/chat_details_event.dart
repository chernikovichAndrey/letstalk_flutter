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

class ChatDetailsSendMedia extends ChatDetailsEvent {
  final File file;
  ChatDetailsSendMedia(this.file);
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

class ChatDetailsDeleteMessage extends ChatDetailsEvent {
  final int messageId;
  ChatDetailsDeleteMessage(this.messageId);
}

class ChatDetailsEditMessage extends ChatDetailsEvent {
  final int messageId;
  final String text;
  ChatDetailsEditMessage(this.messageId, this.text);
}

class ChatDetailsSetAttachedMedia extends ChatDetailsEvent {
  final Media? media;
  ChatDetailsSetAttachedMedia(this.media);
}

class ChatDetailsSetEditingMessage extends ChatDetailsEvent {
  final Message? message;
  ChatDetailsSetEditingMessage(this.message);
}

class ChatDetailsUpdateMessage extends ChatDetailsEvent {
  final Message message;
  ChatDetailsUpdateMessage(this.message);
}
