import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:gal/gal.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/service/websocket_service.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/chats/data/model/media_model.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/domain/repository/chat_details_repository.dart';
import 'package:lets_talk/feature/chats/domain/repository/media_repository.dart';
import 'package:lets_talk/feature/settings/data/model/user_model.dart';

part 'chat_details_event.dart';

part 'chat_details_state.dart';

@singleton
class ChatDetailsBloc extends Bloc<ChatDetailsEvent, ChatDetailsState> {
  final Logger _logger = Logger();
  final ChatDetailsRepository _chatDetailsRepository;
  final MediaRepository _mediaRepository;
  final WebSocketService _wsService;
  StreamSubscription? _wsSubscription;
  static const int _limit = 20;

  late final Map<String, Function(Map<String, dynamic>)> _messageHandlers = {
    'new_message': _handleNewMessage,
    'message_sent': _handleSentMessage,
    'message_edit_success': _handleEditMessageSuccess,
    'read_confirmed': _handleReadConfirmed,
    'message_read': _handleMessageRead,
    'user_typing': _handleUserTypingMessage,
    'chat_avatar_updated': _handleChatAvatarUpdated,
  };

  ChatDetailsBloc(
    this._chatDetailsRepository,
    this._mediaRepository,
    this._wsService,
  ) : super(const ChatDetailsState()) {
    on<ChatDetailsLoad>(_onLoad);
    on<ChatDetailsLoadMore>(_onLoadMore);
    on<ChatDetailsSendMessage>(_onSendMessage);
    on<ChatDetailsSendMedia>(_onSendMedia);
    on<ChatDetailsSendTyping>(_onSendTyping);
    on<ChatDetailsUserTyping>(_onUserTyping);
    on<ChatDetailsNewMessageReceived>(_onNewMessageReceived);
    on<ChatDetailsErrorReceived>(_onErrorReceived);
    on<ChatDetailsDeleteMessage>(_onDeleteMessage);
    on<ChatDetailsEditMessage>(_onEditMessage);
    on<ChatDetailsSetEditingMessage>(_onSetEditingMessage);
    on<ChatDetailsReplyToMessage>(_onReplyToMessage);
    on<ChatDetailsSetAttachedMedia>(_onSetAttachedMedia);
    on<ChatDetailsUpdateMessage>(_onUpdateMessage);
    on<ChatDetailsReadMessage>(_onReadMessage);
    on<DownloadDocument>(_onDownloadDocument);
    on<SaveImageToGallery>(_onSaveImageToGallery);
    on<ChatDetailsDownloadProgress>(_onDownloadProgress);
    on<RefreshStateEvent>(_onRefreshState);
    on<AddMembersToChat>(_onAddMembersToChat);
    on<RemoveMemberFromChat>(_onRemoveMemberFromChat);
    on<UpdateChatAvatar>(_onUpdateChatAvatar);
    on<ChatDetailsUpdatedAvatar>(_onChatDetailsUpdatedAvatar);

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
        _logger.e('WebSocket error in ChatDetailsBloc: $error');
        add(ChatDetailsErrorReceived(error.toString()));
      },
    );
  }

  void _handleWebSocketMessage(Map<String, dynamic> data) {
    final handler = _messageHandlers[data['type']];
    handler?.call(data);
  }

  void _handleNewMessage(Map<String, dynamic> decoded) {
    final msg = Message.fromJson(decoded['message']);
    if (state.chat?.id == msg.chatId) {
      _chatDetailsRepository.markAsRead(msg.chatId, msg.id);
    }
    add(ChatDetailsNewMessageReceived(msg));
  }

  void _handleSentMessage(Map<String, dynamic> decoded) {
    final msg = Message.fromJson(decoded['message']);
    add(ChatDetailsNewMessageReceived(msg));
  }

  void _handleEditMessageSuccess(Map<String, dynamic> decoded) {
    final msg = Message.fromJson(decoded['message']);
    add(ChatDetailsUpdateMessage(msg));
  }

  void _handleReadConfirmed(Map<String, dynamic> decoded) {
    add(ChatDetailsReadMessage(decoded['chat_id'], decoded['message_id']));
  }

  void _handleMessageRead(Map<String, dynamic> decoded) {
    add(ChatDetailsReadMessage(decoded['chat_id'], decoded['message_id']));
  }

  void _handleUserTypingMessage(Map<String, dynamic> decoded) {
    final chatId = decoded['chat_id'] as int;
    if (state.chat?.id == chatId) {
      add(ChatDetailsUserTyping(
        decoded['user_id'] as int,
        decoded['is_typing'] as bool,
      ));
    }
  }

  void _handleChatAvatarUpdated(Map<String, dynamic> decoded) {
    final chatId = decoded['chat_id'] as int;
    if (state.chat?.id == chatId) {
      add(ChatDetailsUpdatedAvatar(
        decoded['avatar'],
      ));
    }
  }

  void _onSetAttachedMedia(
    ChatDetailsSetAttachedMedia event,
    Emitter<ChatDetailsState> emit,
  ) {
    emit(state.copyWith(
      attachedMedia: event.media,
      clearAttachedMedia: event.media == null,
    ));
  }

  void _onUpdateMessage(
    ChatDetailsUpdateMessage event,
    Emitter<ChatDetailsState> emit,
  ) {
    final messages = state.messages.map((m) {
      return m.id == event.message.id ? event.message : m;
    }).toList();
    emit(state.copyWith(messages: messages));
  }

  void _onReadMessage(
    ChatDetailsReadMessage event,
    Emitter<ChatDetailsState> emit,
  ) {
    if (state.chat?.id != event.chatId) return;

    bool hasChanges = false;
    final messages = state.messages.map((m) {
      if (m.id <= event.messageId && !m.read) {
        hasChanges = true;
        return m.copyWith(read: true);
      }
      return m;
    }).toList();

    if (hasChanges) {
      emit(state.copyWith(messages: messages));
    }
  }

  Future<void> _onSaveImageToGallery(
    SaveImageToGallery event,
    Emitter<ChatDetailsState> emit,
  ) async {
    emit(state.copyWith(
      downloadingMessageId: event.messageId,
      downloadProgress: 0,
      clearDownloadSuccess: true,
    ));

    try {
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/${event.filename}';

      await _mediaRepository.downloadMedia(
        event.imageUrl,
        savePath,
        onReceiveProgress: (count, total) {
          add(ChatDetailsDownloadProgress(count, total, event.messageId));
        },
      );

      await Gal.putImage(savePath);

      final file = File(savePath);
      if (await file.exists()) {
        await file.delete();
      }

      if (state.downloadingMessageId == event.messageId) {
        emit(state.copyWith(
          clearDownloadingMessageId: true,
          clearDownloadProgress: true,
          isDownloadSuccess: true,
        ));
      } else {
        emit(state.copyWith(isDownloadSuccess: true));
      }
    } catch (e) {
      if (state.downloadingMessageId == event.messageId) {
        emit(state.copyWith(
          status: ChatDetailsStatus.failure,
          errorMessage: e.toString(),
          clearDownloadingMessageId: true,
          clearDownloadProgress: true,
        ));
      } else {
        emit(state.copyWith(
          status: ChatDetailsStatus.failure,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  Future<void> _onDownloadDocument(
    DownloadDocument event,
    Emitter<ChatDetailsState> emit,
  ) async {
    emit(state.copyWith(
      downloadingMessageId: event.messageId,
      downloadProgress: 0,
      clearDownloadSuccess: true,
    ));

    try {
      await _mediaRepository.downloadMedia(
        event.mediaUrl,
        event.savePath,
        onReceiveProgress: (count, total) {
          add(ChatDetailsDownloadProgress(count, total, event.messageId));
        },
      );
      
      if (state.downloadingMessageId == event.messageId) {
        emit(state.copyWith(
          clearDownloadingMessageId: true,
          clearDownloadProgress: true,
          isDownloadSuccess: true,
        ));
      } else {
        emit(state.copyWith(isDownloadSuccess: true));
      }
    } catch (e) {
      if (state.downloadingMessageId == event.messageId) {
        emit(state.copyWith(
          status: ChatDetailsStatus.failure,
          errorMessage: e.toString(),
          clearDownloadingMessageId: true,
          clearDownloadProgress: true,
        ));
      } else {
         emit(state.copyWith(
          status: ChatDetailsStatus.failure,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  void _onDownloadProgress(
    ChatDetailsDownloadProgress event,
    Emitter<ChatDetailsState> emit,
  ) {
    if (state.downloadingMessageId == event.messageId && event.total != -1) {
      emit(state.copyWith(
        downloadProgress: event.count / event.total,
      ));
    }
  }

  void _onSetEditingMessage(
    ChatDetailsSetEditingMessage event,
    Emitter<ChatDetailsState> emit,
  ) {
    emit(state.copyWith(
      messageToEdit: event.message,
      clearMessageToEdit: event.message == null,
      clearReplyMessage: true,
    ));
  }

  void _onReplyToMessage(
    ChatDetailsReplyToMessage event,
    Emitter<ChatDetailsState> emit,
  ) {
    emit(state.copyWith(
      replyMessage: event.message,
      clearReplyMessage: event.message == null,
      clearMessageToEdit: true,
    ));
  }

  Future<void> _onEditMessage(
    ChatDetailsEditMessage event,
    Emitter<ChatDetailsState> emit,
  ) async {
    try {
      await _chatDetailsRepository.editMessage(event.messageId, event.text);
      emit(state.copyWith(clearMessageToEdit: true));
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatDetailsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteMessage(
    ChatDetailsDeleteMessage event,
    Emitter<ChatDetailsState> emit,
  ) async {
    try {
      await _chatDetailsRepository.deleteMessage(event.messageId);
      final messages = state.messages.where((m) => m.id != event.messageId).toList();
      emit(state.copyWith(messages: messages));
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatDetailsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
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

  Future<void> _onUserTyping(
    ChatDetailsUserTyping event,
    Emitter<ChatDetailsState> emit,
  ) async {
    if (event.isTyping) {
      emit(
        state.copyWith(
          typingUserIds: {event.userId},
        )
      );
    } else {
      final typingIds = state.typingUserIds;
      typingIds.remove(event.userId);
      emit(
        state.copyWith(
          typingUserIds: typingIds,
        )
      );
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
      await _chatDetailsRepository.sendMessage(
        chatId,
        event.text,
        mediaId: state.attachedMedia?.id,
        messageType: state.attachedMedia?.type,
        replyToMessageId: state.replyMessage?.id,
      );
      emit(state.copyWith(
        clearAttachedMedia: true,
        clearReplyMessage: true,
      ));
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatDetailsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSendMedia(
    ChatDetailsSendMedia event,
    Emitter<ChatDetailsState> emit,
  ) async {
    final chatId = state.chat?.id;
    if (chatId == null) return;

    try {
      final fileType = _getFileType(event.file.path);
      final media = await _mediaRepository.uploadMedia(
        file: event.file,
        chatId: chatId,
        fileType: fileType,
      );
      emit(state.copyWith(attachedMedia: media));
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatDetailsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  String _getFileType(String path) {
    final ext = path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext)) {
      return 'image';
    } else if (['mp4', 'mov', 'avi', 'mkv'].contains(ext)) {
      return 'video';
    } else if (['mp3', 'wav', 'aac', 'm4a'].contains(ext)) {
      return 'audio';
    }
    return 'document';
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
          await _chatDetailsRepository.markAsRead(event.chatId, messages.last.id);
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

  Future<void> _onRefreshState(
    RefreshStateEvent event,
    Emitter<ChatDetailsState> emit,
  ) async {
    emit(const ChatDetailsState());
  }

  Future<void> _onAddMembersToChat(
    AddMembersToChat event,
    Emitter<ChatDetailsState> emit,
  ) async {
    if (state.chat == null) return;
    await _chatDetailsRepository.addMemberToChat(chatId: state.chat!.id, userId: event.userId);
    add(ChatDetailsLoad(state.chat!.id, state.currentUser!));
  }

  Future<void> _onRemoveMemberFromChat(
    RemoveMemberFromChat event,
    Emitter<ChatDetailsState> emit,
  ) async {
    if (state.chat == null) return;
    try {
      await _chatDetailsRepository.removeMemberFromChat(
        chatId: state.chat!.id,
        userId: event.userId,
      );
      add(ChatDetailsLoad(state.chat!.id, state.currentUser!));
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatDetailsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateChatAvatar(
    UpdateChatAvatar event,
    Emitter<ChatDetailsState> emit,
  ) async {
    if (state.chat == null) return;
    emit(state.copyWith(status: ChatDetailsStatus.loading));
    try {
      final avatarUrl = await _chatDetailsRepository.updateChatAvatar(
        chatId: state.chat!.id,
        file: event.file,
      );
      emit(state.copyWith(
        status: ChatDetailsStatus.success,
        chat: state.chat!.copyWith(avatar: avatarUrl),
      ));
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatDetailsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onChatDetailsUpdatedAvatar(
    ChatDetailsUpdatedAvatar event,
    Emitter<ChatDetailsState> emit,
  ) {
    emit(
      state.copyWith(
        chat: state.chat?.copyWith(
          avatar: event.avatarUrl,
        )
      )
    );
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    return super.close();
  }
}
