import 'package:lets_talk/common/constants/api_constants.dart';
import 'package:lets_talk/common/service/api_service.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/domain/repository/chats_repository.dart';

class ChatsRepositoryImpl implements ChatsRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<List<Chat>> getChats() async {
    final response = await _apiService.get(ApiConstants.chats);
    final chatsResponse = ChatsResponse.fromJson(response.data);
    return chatsResponse.chats;
  }

  @override
  Future<List<Chat>> searchChats(String query) async {
    final response = await _apiService.get(
      ApiConstants.chatsSearch,
      queryParameters: {'q': query},
    );
    final chatsResponse = ChatsResponse.fromJson(response.data);
    return chatsResponse.chats;
  }

  @override
  Future<List<Message>> getMessages(
    int chatId, {
    int? limit,
    int? fromMessageId,
    int? toMessageId,
  }) async {
    final queryParameters = {'limit': limit};
    if (fromMessageId != null) {
      queryParameters['from_message_id'] = fromMessageId;
    }
    if (toMessageId != null) {
      queryParameters['to_message_id'] = toMessageId;
    }

    final response = await _apiService.get(
      '${ApiConstants.messages}/$chatId',
      queryParameters: queryParameters,
    );
    final messagesResponse = MessagesResponse.fromJson(response.data);
    return messagesResponse.messages;
  }
}
