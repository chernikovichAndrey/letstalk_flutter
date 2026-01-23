import 'package:lets_talk/common/constants/api_constants.dart';
import 'package:lets_talk/common/service/api_service.dart';
import 'package:lets_talk/common/service/websocket_service.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/domain/repository/chat_details_repository.dart';

class ChatDetailsRepositoryImpl extends ChatDetailsRepository {
  final _apiService = ApiService();
  final _wsService = WebSocketService();

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

  @override
  Future<void> markAsRead(int chatId, int messageId) async {
    _wsService.readMessage(chatId, messageId);
  }

  @override
  Future<void> sendMessage(int chatId, String text) async {
    WebSocketService().sendMessage(chatId, text);
  }

  @override
  Future<void> sendTyping(int chatId, bool isTyping) async {
    _wsService.sendTyping(chatId, isTyping);
  }

  @override
  Future<void> deleteMessage(int messageId) async {
    await _apiService.delete('${ApiConstants.messages}/$messageId');
  }

  @override
  Future<void> editMessage(int messageId, String text) async {
    _wsService.editMessage(messageId, text);
  }

  @override
  Future<ChatDetailsResponse> getChatDetails(int chatId) async {
    final response = await _apiService.get(
      '${ApiConstants.chats}/$chatId',
    );
    return ChatDetailsResponse.fromJson(response.data);
  }
}