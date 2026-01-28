import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:lets_talk/common/service/websocket_service.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/domain/repository/chats_repository.dart';
import 'package:lets_talk/feature/settings/data/model/user_model.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';
import 'package:logger/logger.dart';

part 'chats_event.dart';
part 'chats_state.dart';

@singleton
class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final Logger _logger = Logger();
  final ChatsRepository _chatsRepository;
  final WebSocketService _wsService;
  final ProfileBloc _profileBloc;
  StreamSubscription? _wsSubscription;
  StreamSubscription? _profileSubscription;
  UserModel? _currentUser;

  late final Map<String, Function(Map<String, dynamic>)> _messageHandlers = {
    'unread_count': _handleUnreadCount,
    'user_typing': _handleUserTyping,
    'message_sent': _handleSentMessage,
    'new_message': _handleNewMessage,
    'chat_member_removed': _handleChatMemberRemoved,
    'chat_member_added': _handleChatMemberAdded,
  };

  ChatsBloc(
    this._chatsRepository,
    this._wsService,
    this._profileBloc,
  ) : super(ChatsInitial()) {
    on<ChatsLoad>(_onLoad);
    on<ChatsRefresh>(_onRefresh);
    on<ChatsSearch>(_onSearch);
    on<ChatMemberRemoved>(_onChatMemberRemoved);
    on<ChatUpdated>(_onChatUpdated);
    on<ChatTypingUpdated>(_onChatTypingUpdated);
    on<ChatsToggleSelectionMode>(_onToggleSelectionMode);
    on<ChatsToggleChatSelection>(_onToggleChatSelection);
    on<RemoveChat>(_onRemoveChat);

    _subscribeToWebSocket();
    _subscribeToProfile();
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
    add(ChatUpdated(chatId: decoded['chat_id'], unreadCount: decoded['count']));
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

  void _handleSentMessage(Map<String, dynamic> decoded) {
    final msg = Message.fromJson(decoded['message']);
    add(
      ChatUpdated(
        chatId: msg.chatId,
        lastMessageId: msg.id,
        lastMessageText: msg.text,
        unreadCount: 0,
      ),
    );
  }

  void _handleNewMessage(Map<String, dynamic> decoded) {
    final msg = Message.fromJson(decoded['message']);
    final unreadCount = UnreadMessagesResponse
        .fromJson(decoded['unreaded_messages'])
        .unreadedMessages
        .firstWhere((unreadMessages) => unreadMessages.chatId == msg.chatId)
        .unread;
    add(
      ChatUpdated(
        chatId: msg.chatId,
        lastMessageId: msg.id,
        lastMessageText: msg.text,
        unreadCount: unreadCount,
      ),
    );
  }

  void _handleChatMemberRemoved(Map<String, dynamic> decoded) {
    if (_currentUser != null && decoded['user_id'] == _currentUser!.id) {
      add(ChatMemberRemoved(decoded['chat_id']));
    }
  }

  void _handleChatMemberAdded(Map<String, dynamic> decoded) async {
    //TODO: add new chat from socket data
    add(ChatsRefresh());
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

  void _onChatMemberRemoved(ChatMemberRemoved event, Emitter<ChatsState> emit) {
    final currentState = state;
    if (currentState is ChatsLoaded) {
      emit(ChatsLoaded(currentState.chats.where((chat) => chat.id != event.chatId).toList()));
    }
  }

  Future<void> _onChatUpdated(ChatUpdated event, Emitter<ChatsState> emit) async {
    final currentState = state;
    if (currentState is ChatsLoaded) {
      List<Chat> updatedChats = currentState.chats.map((chat) {
        if (chat.id == event.chatId) {
          return chat.copyWith(
            unreadCount: event.unreadCount ?? chat.unreadCount,
            lastMessageId: event.lastMessageId ?? chat.lastMessageId,
            lastMessageText: event.lastMessageText ?? chat.lastMessageText,
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
    final currentState = state;
    if (_currentUser == null || currentState is! ChatsLoaded) return;

    if (event.type == RemoveType.all) {
      final chat = currentState.chats.firstWhere((chat) => chat.id == event.chatId);

      if (chat.type == 'group' &&
          chat.role == 'admin' &&
          chat.memberInfo != null) {
        await Future.wait(
          chat.memberInfo!
              .where((member) => member.id != _currentUser!.id)
              .map((member) =>
              _chatsRepository.removeMemberFromChat(
                chatId: event.chatId,
                userId: member.id,
              ),
          ),
        );
      }
    }
    await _chatsRepository.removeMemberFromChat(
      chatId: event.chatId,
      userId: _currentUser!.id,
    );
  }

  void _subscribeToProfile() {
    _profileSubscription = _profileBloc.stream.listen((profileState) {
      if (profileState is ProfileLoaded) {
        _currentUser = profileState.user;
      } else if (profileState is AvatarUploadLoading) {
        _currentUser = profileState.user;
      } else if (profileState is ProfileSaving) {
        _currentUser = profileState.user;
      }
    });

    final currentProfileState = _profileBloc.state;
    if (currentProfileState is ProfileLoaded) {
      _currentUser = currentProfileState.user;
    }
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    _profileSubscription?.cancel();
    return super.close();
  }
}
