import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:lets_talk/common/service/websocket_service.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/chats/domain/repository/chats_repository.dart';
import 'package:logger/logger.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

@singleton
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  final Logger _logger = Logger();
  final ChatsRepository _chatsRepository;
  final WebSocketService _wsService;
  StreamSubscription? _wsSubscription;

  late final Map<String, Function(Map<String, dynamic>)> _messageHandlers = {
    'new_message': _handleNewMessage,
    'unread_count': _handleMessageRead,
    'message_deleted': _handleChatMessageDeleted,
    'missed_call': _handleMissedCall,
    'message_forwarded': _handleMessageForwarded,
  };

  NavigationBloc(
    this._chatsRepository,
    this._wsService,
  ) : super(NavigationState.initial()) {
    on<NavigationInitEvent>(_onNavigationInitEvent);
    on<NavigationMessageReceived>(_onMessageReceived);
    on<NavigationMessageRead>(_onMessageRead);
    on<NavigationCallMissed>(_onCallMissed);
    on<NavigationUpdateUnreadCount>(_onUpdateUnreadCount);
    on<NavigationReset>(_onReset);
    _subscribeToWebSocket();
  }

  void _subscribeToWebSocket() {
    _wsSubscription = _wsService.signalingStream.listen(
      (message) {
        _handleWebSocketMessage(message);
      },
      onError: (error) {
        _logger.e('WebSocket error in NavigationBloc: $error');
      },
    );
  }

  void _handleWebSocketMessage(Map<String, dynamic> data) {
    final handler = _messageHandlers[data['type']];
    handler?.call(data);
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    final unreadCount = UnreadMessagesResponse
        .fromJson(data['unreaded_messages'])
        .unreadedMessages
        .fold(0, (sum, message) => sum + message.unread);

    add(NavigationUpdateUnreadCount(unreadCount));
  }

  void _handleChatMessageDeleted(Map<String, dynamic> data) {
    final unreadCount = UnreadMessagesResponse
        .fromJson(data['unreaded_messages'])
        .unreadedMessages
        .fold(0, (sum, message) => sum + message.unread);
        
    add(NavigationUpdateUnreadCount(unreadCount));
  }

  void _handleMessageForwarded(Map<String, dynamic> data) {
    add(NavigationUpdateUnreadCount(state.unreadChatsCount));
  }

  void _handleMessageRead(Map<String, dynamic> data) {
    add(NavigationMessageRead());
  }

  void _handleMissedCall(Map<String, dynamic> data) {
    add(NavigationCallMissed());
  }

  Future<void> _onNavigationInitEvent(
    NavigationInitEvent event,
    Emitter<NavigationState> emit,
  ) async {
    final chats = await _chatsRepository.getChats();
    final totalUnreadCount = chats.fold(0, (sum, chat) => sum + chat.unreadCount);
    emit(state.copyWith(unreadChatsCount: totalUnreadCount));
  }

  void _onMessageReceived(
    NavigationMessageReceived event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(unreadChatsCount: state.unreadChatsCount + 1));
  }

  void _onMessageRead(
    NavigationMessageRead event,
    Emitter<NavigationState> emit,
  ) async {
    final chats = await _chatsRepository.getChats();
    final totalUnreadCount = chats.fold(0, (sum, chat) => sum + chat.unreadCount);
    emit(state.copyWith(unreadChatsCount: totalUnreadCount));
  }

  void _onCallMissed(
    NavigationCallMissed event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(missedCallsCount: state.missedCallsCount + 1));
  }

  void _onUpdateUnreadCount(
    NavigationUpdateUnreadCount event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(unreadChatsCount: event.count));
  }

  void _onReset(
    NavigationReset event,
    Emitter<NavigationState> emit,
  ) {
    emit(NavigationState.initial());
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    return super.close();
  }
}
