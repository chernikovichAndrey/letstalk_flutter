import 'package:lets_talk/feature/chats/data/model/media_model.dart';

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
  final dynamic replyTo;
  final dynamic forwardedFrom;

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
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: int.tryParse(json['id'].toString()) ?? 0,
      chatId: int.tryParse(json['chat_id'].toString()) ?? 0,
      fromUserId: int.tryParse(json['from_user_id'].toString()) ?? 0,
      fromPhone: json['from_phone'] as String?,
      text: json['text'] as String?,
      messageType: json['message_type'] as String? ?? 'text',
      media: json['media'] != null ? Media.fromJson(json['media']) : null,
      read: json['read'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
      isEdited: json['is_edited'] as bool? ?? false,
      editedAt: json['edited_at'] as String?,
      editCount: int.tryParse(json['edit_count'].toString()) ?? 0,
      replyTo: json['reply_to'],
      forwardedFrom: json['forwarded_from'],
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
    dynamic replyTo,
    dynamic forwardedFrom,
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
