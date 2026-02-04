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
  final File? file;
  ChatDetailsSendMessage(this.text, {this.file});
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

class ChatDetailsUploadProgress extends ChatDetailsEvent {
  final String tempMessageId;
  final double progress;

  ChatDetailsUploadProgress(this.tempMessageId, this.progress);
}

class ChatDetailsSendTyping extends ChatDetailsEvent {
  final bool isTyping;
  ChatDetailsSendTyping(this.isTyping);
}

class ChatDetailsUserTyping extends ChatDetailsEvent {
  final int userId;
  final bool isTyping;
  ChatDetailsUserTyping(this.userId, this.isTyping);
}

class ChatDetailsNewMessageReceived extends ChatDetailsEvent {
  final Message message;
  final String? tempMessageId;
  ChatDetailsNewMessageReceived(this.message, {this.tempMessageId});
}

class ChatDetailsErrorReceived extends ChatDetailsEvent {
  final String error;
  ChatDetailsErrorReceived(this.error);
}

class ChatDetailsDeleteMessage extends ChatDetailsEvent {
  final int messageId;
  final bool isOtherDeleted;
  ChatDetailsDeleteMessage(this.messageId, {this.isOtherDeleted = false});
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

class ChatDetailsReplyToMessage extends ChatDetailsEvent {
  final Message? message;
  ChatDetailsReplyToMessage(this.message);
}

class ChatDetailsUpdateMessage extends ChatDetailsEvent {
  final Message message;
  ChatDetailsUpdateMessage(this.message);
}

class ChatDetailsReadMessage extends ChatDetailsEvent {
  final int chatId;
  final int messageId;
  ChatDetailsReadMessage(this.chatId, this.messageId);
}

class RefreshStateEvent extends ChatDetailsEvent {}

class AddMembersToChat extends ChatDetailsEvent {
  final int userId;

  AddMembersToChat(this.userId);
}

class RemoveMemberFromChat extends ChatDetailsEvent {
  final int userId;

  RemoveMemberFromChat(this.userId);
}

class UpdateChatAvatar extends ChatDetailsEvent {
  final File file;

  UpdateChatAvatar(this.file);
}

class ChatDetailsUpdatedAvatar extends ChatDetailsEvent {
  final String avatarUrl;

  ChatDetailsUpdatedAvatar(this.avatarUrl);
}
