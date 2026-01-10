import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';

abstract class ChatsRepository {
  Future<List<Chat>> getChats();
  Future<List<Chat>> searchChats(String query);
  Future<List<Message>> getMessages(int chatId, {int limit, int? fromMessageId});
}
