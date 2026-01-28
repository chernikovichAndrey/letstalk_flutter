import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:lets_talk/common/service/websocket_service.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/domain/repository/chats_repository.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';
import 'package:logger/logger.dart';

part 'chats_event.dart';
part 'chats_state.dart';

@singleton
class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final Logger _logger = Logger();
  final ChatsRepository _chatsRepository;
  final WebSocketService _wsService;
  StreamSubscription? _wsSubscription;

  late final Map<String, Function(Map<String, dynamic>)> _messageHandlers = {
    'unread_count': _handleUnreadCount,
    'user_typing': _handleUserTyping,
    'new_message': _handleNewMessage
  };


  ChatsBloc(
    this._chatsRepository,
    this._wsService,
  ) : super(ChatsInitial()) {
    on<ChatsLoad>(_onLoad);
    on<ChatsRefresh>(_onRefresh);
    on<ChatsSearch>(_onSearch);
    on<UpdateUnreadCount>(_onUpdateUnreadCount);
    on<ChatUpdated>(_onChatUpdated);
    on<ChatTypingUpdated>(_onChatTypingUpdated);
    on<ChatsToggleSelectionMode>(_onToggleSelectionMode);
    on<ChatsToggleChatSelection>(_onToggleChatSelection);
    on<ChatsDeleteSelected>(_onDeleteSelected);
    on<RemoveChat>(_onRemoveChat);

    _subscribeToWebSocket();
  }

  void _subscribeToWebSocket() {
    _wsSubscription = _wsService.stream.listen(
          (message) {
        if (message is String) {
          final decoded = jsonDecode(message);
          _handleWebSocketMessage(decoded);
        }
      },
      onError: (error) {
        _logger.e('WebSocket error in ChatsBloc: $error');
      },
    );
  }

  void _handleWebSocketMessage(Map<String, dynamic> data) {
    final handler = _messageHandlers[data['type']];
    handler?.call(data);
  }

  void _handleUnreadCount(Map<String, dynamic> decoded) {
    add(
      UpdateUnreadCount(decoded['chat_id'], decoded['count'])
    );
  }

  void _handleUserTyping(Map<String, dynamic> decoded) {
    add(
      ChatTypingUpdated(
        chatId: decoded['chat_id'],
        userId: decoded['user_id'],
        isTyping: decoded['is_typing'],
      ),
    );
  }

  void _handleNewMessage(Map<String, dynamic> decoded) {
    final msg = Message.fromJson(decoded['message']);
    add(
      ChatTypingUpdated(
        chatId: msg.chatId,
        userId: msg.fromUserId,
        isTyping: false,
      ),
    );
    add(ChatUpdated(msg.chatId, msg));
  }

  void _onToggleSelectionMode(
    ChatsToggleSelectionMode event,
    Emitter<ChatsState> emit,
  ) {
    final currentState = state;
    if (currentState is ChatsLoaded) {
      emit(ChatsLoaded(
        currentState.chats,
        typingUsers: currentState.typingUsers,
        isSelectionMode: !currentState.isSelectionMode,
        selectedChatIds: {},
      ));
    }
  }

  void _onToggleChatSelection(
    ChatsToggleChatSelection event,
    Emitter<ChatsState> emit,
  ) {
    final currentState = state;
    if (currentState is ChatsLoaded) {
      final selectedChatIds = Set<int>.from(currentState.selectedChatIds);
      if (selectedChatIds.contains(event.chatId)) {
        selectedChatIds.remove(event.chatId);
      } else {
        selectedChatIds.add(event.chatId);
      }
      emit(ChatsLoaded(
        currentState.chats,
        typingUsers: currentState.typingUsers,
        isSelectionMode: currentState.isSelectionMode,
        selectedChatIds: selectedChatIds,
      ));
    }
  }

  Future<void> _onDeleteSelected(
    ChatsDeleteSelected event,
    Emitter<ChatsState> emit,
  ) async {
    final currentState = state;
    if (currentState is ChatsLoaded) {
      try {
        final userId = (getIt<ProfileBloc>() as ProfileLoaded).user.id;
        for (final chatId in currentState.selectedChatIds) {
          await _chatsRepository.removeMemberFromChat(chatId: chatId, userId: userId);
        }
        add(ChatsRefresh());
      } catch (e) {
        emit(ChatsError(e.toString()));
      }
    }
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    return super.close();
  }

  void _onChatTypingUpdated(
    ChatTypingUpdated event,
    Emitter<ChatsState> emit,
  ) {
    final currentState = state;
    if (currentState is ChatsLoaded) {
      final newTypingUsers = Map<int, Set<int>>.from(currentState.typingUsers);
      final chatTyping = Set<int>.from(newTypingUsers[event.chatId] ?? {});

      if (event.isTyping) {
        chatTyping.add(event.userId);
      } else {
        chatTyping.remove(event.userId);
      }

      if (chatTyping.isEmpty) {
        newTypingUsers.remove(event.chatId);
      } else {
        newTypingUsers[event.chatId] = chatTyping;
      }

      emit(ChatsLoaded(
        currentState.chats,
        typingUsers: newTypingUsers,
        isSelectionMode: currentState.isSelectionMode,
        selectedChatIds: currentState.selectedChatIds,
      ));
    }
  }

  void _onUpdateUnreadCount(UpdateUnreadCount event, Emitter<ChatsState> emit) {
    final currentState = state;
    if (currentState is ChatsLoaded) {
      List<Chat> updatedChats = currentState.chats.map((chat) {
        if (chat.id == event.chatId) {
          return chat.copyWith(
            unreadCount: event.count,
          );
        }
        return chat;
      }).toList();
      emit(ChatsLoaded(
        updatedChats,
        typingUsers: currentState.typingUsers,
        isSelectionMode: currentState.isSelectionMode,
        selectedChatIds: currentState.selectedChatIds,
      ));
    }
  }

  Future<void> _onChatUpdated(ChatUpdated event, Emitter<ChatsState> emit) async {
    final currentState = state;
    if (currentState is ChatsLoaded) {
      try {
        late List<Chat> updatedChats;
        if (event.message == null) {
          final chatDetails = await _chatsRepository.getChatDetails(event.chatId);
          updatedChats = currentState.chats.map((chat) {
            return chat.id == event.chatId ? chatDetails.chat : chat;
          }).toList();
        } else {
          updatedChats = currentState.chats.map((chat) {
            if (chat.id == event.chatId) {
              return chat.copyWith(
                unreadCount: chat.unreadCount + 1,
                lastMessageId: event.message!.id,
                lastMessageText: event.message!.text,
              );
            }
            return chat;
          }).toList();
        }
        emit(ChatsLoaded(
          updatedChats,
          typingUsers: currentState.typingUsers,
          isSelectionMode: currentState.isSelectionMode,
          selectedChatIds: currentState.selectedChatIds,
        ));
      } catch (_) {}
    }
  }

  Future<void> _onLoad(ChatsLoad event, Emitter<ChatsState> emit) async {
    emit(ChatsLoading());
    try {
      final chats = await _chatsRepository.getChats();
      emit(ChatsLoaded(chats));
    } catch (e) {
      emit(ChatsError(e.toString()));
    }
  }

  Future<void> _onRefresh(ChatsRefresh event, Emitter<ChatsState> emit) async {
    try {
      final chats = await _chatsRepository.getChats();
      emit(ChatsLoaded(chats));
    } catch (e) {
      emit(ChatsError(e.toString()));
    } finally {
      event.completer?.complete();
    }
  }

  Future<void> _onSearch(ChatsSearch event, Emitter<ChatsState> emit) async {
    try {
      final chats = event.query.isEmpty
          ? await _chatsRepository.getChats()
          : await _chatsRepository.searchChats(event.query);
      emit(ChatsLoaded(chats));
    } catch (e) {
      emit(ChatsError(e.toString()));
    }
  }

  Future<void> _onRemoveChat(
    RemoveChat event,
    Emitter<ChatsState> emit
  ) async {
    final chats = await _chatsRepository.getChats();
    for (var userId in event.userIds) {
      await _chatsRepository.removeMemberFromChat(chatId: event.chatId, userId: userId);
      emit(ChatsLoaded(chats.where((chat) => chat.id != event.chatId).toList()));
    }
  }
}
