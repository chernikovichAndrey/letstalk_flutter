import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';

abstract class ChatDetailsRepository {
  Future<List<Message>> getMessages(int chatId, {int limit, int? fromMessageId, int? toMessageId});
  Future<void> markAsRead(int chatId, int messageId);
  Future<void> sendMessage(int chatId, String text);
  Future<void> sendTyping(int chatId, bool isTyping);
  Future<void> deleteMessage(int messageId);
  Future<void> editMessage(int messageId, String text);
  Future<ChatDetailsResponse> getChatDetails(int chatId);
}