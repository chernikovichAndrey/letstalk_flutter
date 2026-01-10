class Message {
  final int id;
  final int chatId;
  final int fromUserId;
  final String? fromPhone;
  final String? text;
  final bool read;
  final String createdAt;

  Message({
    required this.id,
    required this.chatId,
    required this.fromUserId,
    this.fromPhone,
    this.text,
    required this.read,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: int.tryParse(json['id'].toString()) ?? 0,
      chatId: int.tryParse(json['chat_id'].toString()) ?? 0,
      fromUserId: int.tryParse(json['from_user_id'].toString()) ?? 0,
      fromPhone: json['from_phone'] as String?,
      text: json['text'] as String?,
      read: json['read'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
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
