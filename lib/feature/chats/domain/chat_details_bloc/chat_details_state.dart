part of 'chat_details_bloc.dart';

enum ChatDetailsStatus { initial, loading, success, failure }

class ChatDetailsState {
  final ChatDetailsStatus status;
  final List<Message> messages;
  final bool hasReachedMax;
  final String? errorMessage;
  final UserModel? currentUser;
  final Chat? chat;
  final List<ChatMember> members;
  final Message? messageToEdit;
  final Message? replyMessage;
  final Media? attachedMedia;
  final int? downloadingMessageId;
  final double? downloadProgress;
  final bool isDownloadSuccess;

  const ChatDetailsState({
    this.status = ChatDetailsStatus.initial,
    this.messages = const [],
    this.hasReachedMax = false,
    this.errorMessage,
    this.currentUser,
    this.chat,
    this.members = const [],
    this.messageToEdit,
    this.replyMessage,
    this.attachedMedia,
    this.downloadingMessageId,
    this.downloadProgress,
    this.isDownloadSuccess = false,
  });

  ChatDetailsState copyWith({
    ChatDetailsStatus? status,
    List<Message>? messages,
    bool? hasReachedMax,
    String? errorMessage,
    UserModel? currentUser,
    Chat? chat,
    List<ChatMember>? members,
    Message? messageToEdit,
    bool clearMessageToEdit = false,
    Message? replyMessage,
    bool clearReplyMessage = false,
    Media? attachedMedia,
    bool clearAttachedMedia = false,
    int? downloadingMessageId,
    bool clearDownloadingMessageId = false,
    double? downloadProgress,
    bool clearDownloadProgress = false,
    bool? isDownloadSuccess,
    bool clearDownloadSuccess = false,
  }) {
    return ChatDetailsState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage,
      currentUser: currentUser ?? this.currentUser,
      chat: chat ?? this.chat,
      members: members ?? this.members,
      messageToEdit: clearMessageToEdit ? null : (messageToEdit ?? this.messageToEdit),
      replyMessage: clearReplyMessage ? null : (replyMessage ?? this.replyMessage),
      attachedMedia: clearAttachedMedia ? null : (attachedMedia ?? this.attachedMedia),
      downloadingMessageId: clearDownloadingMessageId ? null : (downloadingMessageId ?? this.downloadingMessageId),
      downloadProgress: clearDownloadProgress ? null : (downloadProgress ?? this.downloadProgress),
      isDownloadSuccess: clearDownloadSuccess ? false : (isDownloadSuccess ?? this.isDownloadSuccess),
    );
  }
}
