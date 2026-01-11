import 'package:lets_talk/common/constants/api_constants.dart';
import 'package:lets_talk/common/service/api_service.dart';
import 'package:lets_talk/common/service/websocket_service.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/domain/repository/chats_repository.dart';

class ChatsRepositoryImpl implements ChatsRepository {
  final _apiService = ApiService();

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
  Future<ChatDetailsResponse> getChatDetails(int chatId) async {
    final response = await _apiService.get(
      '${ApiConstants.chats}/$chatId',
    );
    return ChatDetailsResponse.fromJson(response.data);
  }
}
