import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/service/websocket_service.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/domain/repository/chat_details_repository.dart';
import 'package:lets_talk/feature/settings/data/model/user_model.dart';

part 'chat_details_event.dart';

part 'chat_details_state.dart';

class ChatDetailsBloc extends Bloc<ChatDetailsEvent, ChatDetailsState> {
  final ChatDetailsRepository _chatDetailsRepository;
  final WebSocketService _wsService = WebSocketService();
  StreamSubscription? _wsSubscription;
  static const int _limit = 20;

  ChatDetailsBloc(this._chatDetailsRepository)
    : super(const ChatDetailsState()) {
    on<ChatDetailsLoad>(_onLoad);
    on<ChatDetailsLoadMore>(_onLoadMore);
    on<ChatDetailsSendMessage>(_onSendMessage);
    on<ChatDetailsSendTyping>(_onSendTyping);
    on<ChatDetailsNewMessageReceived>(_onNewMessageReceived);
    on<ChatDetailsErrorReceived>(_onErrorReceived);

    _subscribeToWebSocket();
  }

  Future<void> _onSendTyping(
    ChatDetailsSendTyping event,
    Emitter<ChatDetailsState> emit,
  ) async {
    final chat = state.chat;
    if (chat != null) {
      await _chatDetailsRepository.sendTyping(chat.id, event.isTyping);
    }
  }

  void _onErrorReceived(
    ChatDetailsErrorReceived event,
    Emitter<ChatDetailsState> emit,
  ) {
    emit(
      state.copyWith(
        status: ChatDetailsStatus.failure,
        errorMessage: event.error,
      ),
    );
  }

  void _subscribeToWebSocket() {
    _wsSubscription = _wsService.stream.listen((message) {
      try {
        if (message is String) {
          final decoded = jsonDecode(message);
          switch (decoded['type']) {
            case 'new_message':
              final msg = Message.fromJson(decoded['message']);
              _chatDetailsRepository.markAsRead(msg.chatId, msg.id);
              add(ChatDetailsNewMessageReceived(msg));
              return;
            case 'message_sent':
              final msg = Message.fromJson(decoded['message']);
              add(ChatDetailsNewMessageReceived(msg));
            default:
              return;
          }
        }
      } catch (e) {
        // Handle parse error or ignore
      }
    });
  }

  void _onNewMessageReceived(
    ChatDetailsNewMessageReceived event,
    Emitter<ChatDetailsState> emit,
  ) {
    if (state.chat?.id == event.message.chatId) {
      emit(state.copyWith(messages: [event.message, ...state.messages]));
    }
  }

  Future<void> _onSendMessage(
    ChatDetailsSendMessage event,
    Emitter<ChatDetailsState> emit,
  ) async {
    final chatId = state.chat?.id;
    if (chatId == null) return;

    try {
      await _chatDetailsRepository.sendMessage(chatId, event.text);
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatDetailsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoad(
    ChatDetailsLoad event,
    Emitter<ChatDetailsState> emit,
  ) async {
    emit(state.copyWith(status: ChatDetailsStatus.loading));
    try {
      final chatDetails = await _chatDetailsRepository.getChatDetails(event.chatId);
      var messages = await _chatDetailsRepository.getMessages(
        event.chatId,
        limit: _limit,
      );

      if (messages.isNotEmpty) {
        try {
          final lastMemberMessageId = messages
              .lastWhere((e) => e.fromUserId != event.user.id);
          await _chatDetailsRepository.markAsRead(event.chatId, lastMemberMessageId.id);
        } catch (_) {}
      }

      emit(
        state.copyWith(
          status: ChatDetailsStatus.success,
          chat: chatDetails.chat,
          members: chatDetails.members,
          messages: messages.reversed.toList(),
          hasReachedMax: messages.length < _limit,
          currentUser: event.user,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatDetailsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadMore(
    ChatDetailsLoadMore event,
    Emitter<ChatDetailsState> emit,
  ) async {
    if (state.hasReachedMax) return;
    if (state.status == ChatDetailsStatus.loading) return;

    emit(state.copyWith(status: ChatDetailsStatus.loading));
    try {
      final lastMessageId = state.messages.isNotEmpty
          ? state.messages.last.id
          : null;
      final messages = await _chatDetailsRepository.getMessages(
        event.chatId,
        limit: _limit,
        toMessageId: lastMessageId,
      );
      emit(
        state.copyWith(
          status: ChatDetailsStatus.success,
          messages: List.of(state.messages)..addAll(messages.reversed),
          hasReachedMax: messages.length < _limit,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatDetailsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    return super.close();
  }
}
