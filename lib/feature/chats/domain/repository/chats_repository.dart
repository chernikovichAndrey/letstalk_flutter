import 'package:lets_talk/feature/chats/data/model/chat_model.dart';

abstract class ChatsRepository {
  Future<List<Chat>> getChats();
}
