import 'dart:io';

import 'package:lets_talk/feature/chats/data/model/chat_model.dart';

abstract class ChatsRepository {
  Future<List<Chat>> getChats();
  Future<List<Chat>> searchChats(String query);
  Future<ChatDetailsResponse> getChatDetails(int chatId);
  Future<CreateChatResponse> createPrivateChat(int userId);
  Future<CreateChatResponse> createGroupChat({
    required List<int> userIds,
    required String title,
    String? avatar,
  });
  Future<void> deleteChat(int chatId);
  Future<void> removeMemberFromChat({
    required int chatId,
    required int userId,
  });
  Future<String> updateChatAvatar({
    required int chatId,
    required File file,
  });
}
