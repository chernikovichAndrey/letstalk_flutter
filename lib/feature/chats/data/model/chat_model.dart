class Chat {
  final int id;
  final String type;
  final String? title;
  final String? avatar;
  final int createdBy;
  final int? lastMessageId;
  final String? lastMessageText;
  final String? lastMessageAt;
  final String? lastMessageType;
  final int unreadCount;
  final int membersCount;
  final String? role;
  final List<MemberInfo>? memberInfo;
  final bool muted;

  Chat({
    required this.id,
    required this.type,
    this.title,
    this.avatar,
    required this.createdBy,
    this.lastMessageId,
    this.lastMessageText,
    this.lastMessageAt,
    this.lastMessageType,
    required this.unreadCount,
    required this.membersCount,
    this.role,
    this.memberInfo,
    this.muted = false,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    print('1111111 ${json}');
    return Chat(
      id: int.tryParse(json['id'].toString()) ?? 0,
      type: json['type'] as String? ?? '',
      title: json['title'] as String?,
      avatar: json['avatar'] as String?,
      createdBy: int.tryParse(json['created_by'].toString()) ?? 0,
      lastMessageId: int.tryParse(json['last_message_id'].toString()),
      lastMessageText: json['last_message_text'] as String?,
      lastMessageAt: json['last_message_at'] as String?,
      lastMessageType: json['last_message_type'] as String?,
      unreadCount: int.tryParse(json['unread_count'].toString()) ?? 0,
      membersCount: int.tryParse(json['members_count'].toString()) ?? 0,
      role: json['role'] as String?,
      memberInfo: (json['member_info'] as List<dynamic>?)
          ?.map((e) => MemberInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      muted: json['is_muted'] as bool? ?? false,
    );
  }

  Chat copyWith({
    int? unreadCount,
    int? lastMessageId,
    String? lastMessageText,
    String? lastMessageType,
    String? lastMessageAt,
    String? avatar,
    bool? muted,
  }) {
    return Chat(
      id: id,
      type: type,
      title: title,
      avatar: avatar ?? this.avatar,
      createdBy: createdBy,
      membersCount: membersCount,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      role: role,
      memberInfo: memberInfo,
      muted: muted ?? this.muted,
    );
  }
}

class MemberInfo {
  final int id;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? avatar;

  MemberInfo({
    required this.id,
    this.phone,
    this.firstName,
    this.lastName,
    this.fullName,
    this.avatar,
  });

  factory MemberInfo.fromJson(Map<String, dynamic> json) {
    return MemberInfo(
      id: int.tryParse(json['id'].toString()) ?? 0,
      phone: json['phone'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      fullName: json['full_name'] as String?,
      avatar: json['avatar'] as String?,
    );
  }
}

class ChatMember {
  final int id;
  final int chatId;
  final int userId;
  final String role;
  final String joinedAt;
  final int? lastReadMessageId;
  final String? phone;

  ChatMember({
    required this.id,
    required this.chatId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.lastReadMessageId,
    this.phone,
  });

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    return ChatMember(
      id: int.tryParse(json['id'].toString()) ?? 0,
      chatId: int.tryParse(json['chat_id'].toString()) ?? 0,
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      role: json['role'] as String? ?? 'member',
      joinedAt: json['joined_at'] as String? ?? '',
      lastReadMessageId: int.tryParse(json['last_read_message_id'].toString()),
      phone: json['phone'] as String?,
    );
  }
}

class ChatsResponse {
  final String status;
  final List<Chat> chats;

  ChatsResponse({
    required this.status,
    required this.chats,
  });

  factory ChatsResponse.fromJson(Map<String, dynamic> json) {
    return ChatsResponse(
      status: json['status'] as String? ?? '',
      chats: (json['chats'] as List<dynamic>?)
              ?.map((e) => Chat.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ChatDetailsResponse {
  final Chat chat;
  final List<ChatMember> members;

  ChatDetailsResponse({
    required this.chat,
    required this.members,
  });

  factory ChatDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ChatDetailsResponse(
      chat: Chat.fromJson(json['chat'] as Map<String, dynamic>),
      members: (json['members'] as List<dynamic>?)
              ?.map((e) => ChatMember.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CreateChatResponse {
  final String status;
  final Chat chat;
  final bool isNew;

  CreateChatResponse({
    required this.status,
    required this.chat,
    required this.isNew,
  });

  factory CreateChatResponse.fromJson(Map<String, dynamic> json) {
    return CreateChatResponse(
      status: json['status'] as String? ?? '',
      chat: Chat.fromJson(json['chat'] as Map<String, dynamic>),
      isNew: json['is_new'] as bool? ?? false,
    );
  }
}

class UnreadMessage {
  final int chatId;
  final int unread;

  UnreadMessage({
    required this.chatId,
    required this.unread,
  });

  factory UnreadMessage.fromJson(Map<String, dynamic> json) {
    return UnreadMessage(
      chatId: int.tryParse(json['chat_id'].toString()) ?? 0,
      unread: int.tryParse(json['unreaded'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_id': chatId,
      'unreaded': unread,
    };
  }
}

class UnreadMessagesResponse {
  final List<UnreadMessage> unreadedMessages;

  UnreadMessagesResponse({
    required this.unreadedMessages,
  });

  factory UnreadMessagesResponse.fromJson(List<dynamic> json) {
    return UnreadMessagesResponse(
      unreadedMessages: json
              .map((e) => UnreadMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  factory UnreadMessagesResponse.fromList(List<dynamic> list) {
    return UnreadMessagesResponse(
      unreadedMessages: list
          .map((e) => UnreadMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
