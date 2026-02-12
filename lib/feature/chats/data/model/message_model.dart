import 'package:lets_talk/feature/chats/data/model/media_model.dart';
import 'package:lets_talk/feature/settings/data/model/user_model.dart';

class ReplyTo {
  final int messageId;
  final int fromUserId;
  final String? fromName;
  final String textPreview;
  final String messageType;
  final Media? media;

  ReplyTo({
    required this.messageId,
    required this.fromUserId,
    this.fromName,
    required this.textPreview,
    required this.messageType,
    this.media,
  });

  factory ReplyTo.fromJson(Map<String, dynamic> json) {
    return ReplyTo(
      messageId: int.tryParse(json['message_id'].toString()) ?? 0,
      fromUserId: int.tryParse(json['from_user_id'].toString()) ?? 0,
      fromName: json['from_name'] as String?,
      textPreview: json['text_preview'] as String? ?? '',
      messageType: json['"msg_type'] as String? ?? 'text',
      media: json['media'] != null ? Media.fromJson(json['media']) : null,
    );
  }
}

class ForwardedFrom {
  final int messageId;
  final int chatId;
  final int fromUserId;
  final String? fromPhone;
  final String fromName;
  final String? text;
  final String createdAt;

  ForwardedFrom({
    required this.messageId,
    required this.chatId,
    required this.fromUserId,
    this.fromPhone,
    required this.fromName,
    this.text,
    required this.createdAt,
  });

  factory ForwardedFrom.fromJson(Map<String, dynamic> json) {
    return ForwardedFrom(
      messageId: int.tryParse(json['message_id'].toString()) ?? 0,
      chatId: int.tryParse(json['chat_id'].toString()) ?? 0,
      fromUserId: int.tryParse(json['from_user_id'].toString()) ?? 0,
      fromPhone: json['from_phone'] as String?,
      fromName: json['from_name'] as String? ?? '',
      text: json['text'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class Message {
  final int id;
  final int chatId;
  final int fromUserId;
  final String? fromPhone;
  final String? text;
  final String messageType;
  final Media? media;
  final bool read;
  final String createdAt;
  final bool isEdited;
  final String? editedAt;
  final int editCount;
  final ReplyTo? replyTo;
  final ForwardedFrom? forwardedFrom;
  final List<UserModel>? fromName;
  final String? tempMessageId;
  final bool isUploading;
  final String? localFilePath;
  final double? uploadProgress;

  Message({
    required this.id,
    required this.chatId,
    required this.fromUserId,
    this.fromPhone,
    this.text,
    required this.messageType,
    this.media,
    required this.read,
    required this.createdAt,
    required this.isEdited,
    this.editedAt,
    required this.editCount,
    this.replyTo,
    this.forwardedFrom,
    this.fromName,
    this.tempMessageId,
    this.isUploading = false,
    this.localFilePath,
    this.uploadProgress,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: int.tryParse(json['id'].toString()) ?? 0,
      chatId: int.tryParse(json['chat_id'].toString()) ?? 0,
      fromUserId: int.tryParse(json['from_user_id'].toString()) ?? 0,
      fromPhone: json['from_phone'] as String?,
      text: json['text'] as String?,
      messageType: json['"msg_type'] as String? ?? 'text',
      media: json['media'] != null ? Media.fromJson(json['media']) : null,
      read: json['read'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
      isEdited: json['is_edited'] as bool? ?? false,
      editedAt: json['edited_at'] as String?,
      editCount: int.tryParse(json['edit_count'].toString()) ?? 0,
      replyTo:
          json['reply_to'] != null ? ReplyTo.fromJson(json['reply_to']) : null,
      forwardedFrom: json['forwarded_from'] != null
          ? ForwardedFrom.fromJson(json['forwarded_from'])
          : null,
      fromName: json['from_name'] != null && json['from_name'] is! String
          ? (json['from_name'] as List<dynamic>)
              .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Message copyWith({
    int? id,
    int? chatId,
    int? fromUserId,
    String? fromPhone,
    String? text,
    String? messageType,
    Media? media,
    bool? read,
    String? createdAt,
    bool? isEdited,
    String? editedAt,
    int? editCount,
    ReplyTo? replyTo,
    ForwardedFrom? forwardedFrom,
    List<UserModel>? fromName,
    String? tempMessageId,
    bool? isUploading,
    String? localFilePath,
    double? uploadProgress,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      fromUserId: fromUserId ?? this.fromUserId,
      fromPhone: fromPhone ?? this.fromPhone,
      text: text ?? this.text,
      messageType: messageType ?? this.messageType,
      media: media ?? this.media,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      editCount: editCount ?? this.editCount,
      replyTo: replyTo ?? this.replyTo,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      fromName: fromName ?? this.fromName,
      tempMessageId: tempMessageId ?? this.tempMessageId,
      isUploading: isUploading ?? this.isUploading,
      localFilePath: localFilePath ?? this.localFilePath,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

class MessagesResponse {
  final String status;
  final List<Message> messages;

  MessagesResponse({
    required this.status,
    required this.messages,
  });

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    return MessagesResponse(
      status: json['status'] as String? ?? '',
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
