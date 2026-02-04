import 'package:injectable/injectable.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';

class ChatCacheData {
  final List<Message> messages;
  final Chat? chat;
  final List<ChatMember> members;
  final bool hasReachedMax;
  final DateTime lastUpdated;

  ChatCacheData({
    required this.messages,
    this.chat,
    this.members = const [],
    this.hasReachedMax = false,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  ChatCacheData copyWith({
    List<Message>? messages,
    Chat? chat,
    List<ChatMember>? members,
    bool? hasReachedMax,
    DateTime? lastUpdated,
  }) {
    return ChatCacheData(
      messages: messages ?? this.messages,
      chat: chat ?? this.chat,
      members: members ?? this.members,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }
}

@singleton
class MessagesCacheService {
  final Map<int, ChatCacheData> _cache = {};

  ChatCacheData? getChatCache(int chatId) {
    return _cache[chatId];
  }

  void setChatCache(int chatId, ChatCacheData data) {
    _cache[chatId] = data;
  }

  void updateMessages(int chatId, List<Message> messages) {
    final existing = _cache[chatId];
    if (existing != null) {
      _cache[chatId] = existing.copyWith(messages: messages);
    }
  }

  void addMessage(int chatId, Message message) {
    final existing = _cache[chatId];
    if (existing != null) {
      final messages = [message, ...existing.messages];
      _cache[chatId] = existing.copyWith(messages: messages);
    }
  }

  void updateMessage(int chatId, Message message) {
    final existing = _cache[chatId];
    if (existing != null) {
      final messages = existing.messages.map((m) {
        if (m.id == message.id) return message;
        if (m.tempMessageId != null && m.tempMessageId == message.tempMessageId) {
          return message;
        }
        return m;
      }).toList();
      _cache[chatId] = existing.copyWith(messages: messages);
    }
  }

  void deleteMessage(int chatId, int messageId) {
    final existing = _cache[chatId];
    if (existing != null) {
      final messages = existing.messages.where((m) => m.id != messageId).toList();
      _cache[chatId] = existing.copyWith(messages: messages);
    }
  }

  void markMessagesAsRead(int chatId, int messageId) {
    final existing = _cache[chatId];
    if (existing != null) {
      final messages = existing.messages.map((m) {
        if (m.id <= messageId && !m.read) {
          return m.copyWith(read: true);
        }
        return m;
      }).toList();
      _cache[chatId] = existing.copyWith(messages: messages);
    }
  }

  void updateChatAvatar(int chatId, String? avatarUrl) {
    final existing = _cache[chatId];
    if (existing?.chat != null) {
      _cache[chatId] = existing!.copyWith(
        chat: existing.chat!.copyWith(avatar: avatarUrl),
      );
    }
  }

  void replaceTemporaryMessage(int chatId, String tempMessageId, Message realMessage) {
    final existing = _cache[chatId];
    if (existing != null) {
      final messages = existing.messages.map((m) {
        return m.tempMessageId == tempMessageId ? realMessage : m;
      }).toList();
      _cache[chatId] = existing.copyWith(messages: messages);
    }
  }

  void removeTempMessage(int chatId, String tempMessageId) {
    final existing = _cache[chatId];
    if (existing != null) {
      final messages = existing.messages.where((m) => m.tempMessageId != tempMessageId).toList();
      _cache[chatId] = existing.copyWith(messages: messages);
    }
  }

  void updateUploadProgress(int chatId, String tempMessageId, double progress) {
    final existing = _cache[chatId];
    if (existing != null) {
      final messages = existing.messages.map((m) {
        if (m.tempMessageId == tempMessageId) {
          return m.copyWith(uploadProgress: progress);
        }
        return m;
      }).toList();
      _cache[chatId] = existing.copyWith(messages: messages);
    }
  }

  void clearCache(int chatId) {
    _cache.remove(chatId);
  }

  void clearAllCache() {
    _cache.clear();
  }
}
