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

class DownloadDocument extends ChatDetailsEvent {
  final String mediaUrl;
  final String savePath;
  final int messageId;

  DownloadDocument({
    required this.mediaUrl,
    required this.savePath,
    required this.messageId,
  });
}

class SaveImageToGallery extends ChatDetailsEvent {
  final String imageUrl;
  final String filename;
  final int messageId;

  SaveImageToGallery({
    required this.imageUrl,
    required this.filename,
    required this.messageId,
  });
}

class ChatDetailsDownloadProgress extends ChatDetailsEvent {
  final int count;
  final int total;
  final int messageId;

  ChatDetailsDownloadProgress(this.count, this.total, this.messageId);
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
