import 'package:injectable/injectable.dart';
import 'package:lets_talk/common/constants/api_constants.dart';
import 'package:lets_talk/common/service/api_service.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/chats/domain/repository/chats_repository.dart';

@LazySingleton(as: ChatsRepository)
class ChatsRepositoryImpl implements ChatsRepository {
  final ApiService _apiService;

  ChatsRepositoryImpl(this._apiService);

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

  @override
  Future<CreateChatResponse> createPrivateChat(int userId) async {
    final response = await _apiService.post(
      ApiConstants.chats,
      data: {
        'type': 'private',
        'user_ids': [userId],
      },
    );
    return CreateChatResponse.fromJson(response.data);
  }

  @override
  Future<CreateChatResponse> createGroupChat({
    required List<int> userIds,
    required String title,
    String? avatar,
  }) async {
    final data = {
      'type': 'group',
      'user_ids': userIds,
      'title': title,
    };
    
    if (avatar != null) {
      data['avatar'] = avatar;
    }

    final response = await _apiService.post(
      ApiConstants.chats,
      data: data,
    );
    return CreateChatResponse.fromJson(response.data);
  }

  @override
  Future<void> deleteChat(int chatId) async {
    await _apiService.delete('${ApiConstants.chats}/$chatId');
  }
}
