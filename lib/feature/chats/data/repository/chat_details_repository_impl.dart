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
  Future<void> sendMessage(
    int chatId,
    String text, {
    int? mediaId,
    String? messageType,
    int? replyToMessageId,
  }) async {
    final Map<String, dynamic> data = {
      'chat_id': chatId,
      'text': text,
    };

    if (replyToMessageId != null) {
      data['reply_to_message_id'] = replyToMessageId;
    }
    
    // Note: The user's request example didn't include mediaId or messageType, 
    // but the previous implementation did. 
    // If the REST API supports them, we should include them.
    // Assuming standard structure based on usage:
    if (mediaId != null) {
      data['media_id'] = mediaId;
    }
    if (messageType != null) {
      data['message_type'] = messageType;
    }

    await _apiService.post(
      ApiConstants.messages,
      data: data,
    );
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