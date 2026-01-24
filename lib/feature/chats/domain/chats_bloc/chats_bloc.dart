import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:lets_talk/common/service/websocket_service.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/chats/domain/repository/chats_repository.dart';

part 'chats_event.dart';
part 'chats_state.dart';

@injectable
class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final ChatsRepository _chatsRepository;
  final WebSocketService _wsService;
  StreamSubscription? _wsSubscription;

  ChatsBloc(
    this._chatsRepository,
    this._wsService,
  ) : super(ChatsInitial()) {
    on<ChatsLoad>(_onLoad);
    on<ChatsRefresh>(_onRefresh);
    on<ChatsSearch>(_onSearch);
    on<ChatUpdated>(_onChatUpdated);
    on<ChatTypingUpdated>(_onChatTypingUpdated);
    on<ChatsToggleSelectionMode>(_onToggleSelectionMode);
    on<ChatsToggleChatSelection>(_onToggleChatSelection);
    on<ChatsDeleteSelected>(_onDeleteSelected);
    _subscribeToWebSocket();
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
        for (final chatId in currentState.selectedChatIds) {
          await _chatsRepository.deleteChat(chatId);
        }
        add(ChatsRefresh());
      } catch (e) {
        emit(ChatsError(e.toString()));
      }
    }
  }

  void _subscribeToWebSocket() {
    _wsSubscription = _wsService.stream.listen((message) {
      if (message is String) {
        try {
          final decoded = jsonDecode(message);
          if (decoded['type'] == 'user_typing') {
            add(ChatTypingUpdated(
              chatId: decoded['chat_id'],
              userId: decoded['user_id'],
              isTyping: decoded['is_typing'],
            ));
          }
        } catch (_) {}
      }
    });
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

  Future<void> _onChatUpdated(ChatUpdated event, Emitter<ChatsState> emit) async {
    final currentState = state;
    if (currentState is ChatsLoaded) {
      try {
        final chatDetails = await _chatsRepository.getChatDetails(event.chatId);
        final updatedChats = currentState.chats.map((chat) {
          return chat.id == event.chatId ? chatDetails.chat : chat;
        }).toList();
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
}
