import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:lets_talk/app/environment/environment.dart';

import 'package:gal/gal.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/service/messages_cache_service.dart';
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
  final MessagesCacheService _cacheService;
  StreamSubscription? _wsSubscription;
  final Map<int, Timer> _typingTimers = {};
  static const int _limit = 20;
  static const Duration _typingTimeout = Duration(seconds: 6);

  late final Map<String, Function(Map<String, dynamic>)> _messageHandlers = {
    'new_message': _handleNewMessage,
    'message_sent': _handleSentMessage,
    'message_edit_success': _handleEditMessageSuccess,
    'message_read': _handleMessageRead,
    'user_typing': _handleUserTypingMessage,
    'chat_avatar_updated': _handleChatAvatarUpdated,
    'message_deleted': _handleChatMessageDeleted,
    'video_ready': _handleVideoReady,
  };

  ChatDetailsBloc(
    this._chatDetailsRepository,
    this._mediaRepository,
    this._wsService,
    this._cacheService,
  ) : super(const ChatDetailsState()) {
    on<ChatDetailsLoad>(_onLoad);
    on<ChatDetailsLoadMore>(_onLoadMore);
    on<ChatDetailsSendMessage>(_onSendMessage);
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
    on<SaveVideoToGallery>(_onSaveVideoToGallery);
    on<ChatDetailsDownloadProgress>(_onDownloadProgress);
    on<ChatDetailsUploadProgress>(_onUploadProgress);
    on<RefreshStateEvent>(_onRefreshState);
    on<AddMembersToChat>(_onAddMembersToChat);
    on<RemoveMemberFromChat>(_onRemoveMemberFromChat);
    on<UpdateChatAvatar>(_onUpdateChatAvatar);
    on<ChatDetailsUpdatedAvatar>(_onChatDetailsUpdatedAvatar);
    on<ChatDetailsVideoReady>(_onVideoReady);

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
    final tempMessageId = decoded['temp_message_id'] as String?;
    add(ChatDetailsNewMessageReceived(msg, tempMessageId: tempMessageId));
  }

  void _handleEditMessageSuccess(Map<String, dynamic> decoded) {
    final msg = Message.fromJson(decoded['message']);
    add(ChatDetailsUpdateMessage(msg));
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

  void _handleChatMessageDeleted(Map<String, dynamic> decoded) {
    final chatId = decoded['chat_id'] as int;
    if (state.chat?.id == chatId) {
      add(ChatDetailsDeleteMessage(decoded['message_id'], isOtherDeleted: true));
    }
  }

  void _handleVideoReady(Map<String, dynamic> decoded) {
    final mediaId = int.tryParse(decoded['media_id'].toString()) ?? 0;
    final filePath = decoded['file_path'] as String? ?? '';
    add(ChatDetailsVideoReady(mediaId: mediaId, filePath: filePath));
  }

  void _onVideoReady(
    ChatDetailsVideoReady event,
    Emitter<ChatDetailsState> emit,
  ) {
    bool hasChanges = false;
    final messages = state.messages.map((m) {
      if (m.media?.id == event.mediaId) {
        hasChanges = true;
        final currentVideoUrl = m.media!.videoUrl;
        final newVideoUrl = (currentVideoUrl == null || currentVideoUrl.isEmpty)
            ? '${Env.baseUrl}/${event.filePath}'
            : currentVideoUrl;
        return m.copyWith(
          media: m.media!.copyWith(status: 'ready', videoUrl: newVideoUrl),
        );
      }
      return m;
    }).toList();

    if (hasChanges) {
      if (state.chat?.id != null) {
        _cacheService.updateMessages(state.chat!.id, messages);
      }
      emit(state.copyWith(messages: messages));
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
    
    // Update cache
    if (state.chat?.id != null) {
      _cacheService.updateMessage(state.chat!.id, event.message);
    }
    
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
      // Update cache
      _cacheService.markMessagesAsRead(event.chatId, event.messageId);
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

  Future<void> _onSaveVideoToGallery(
    SaveVideoToGallery event,
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
        event.videoUrl,
        savePath,
        onReceiveProgress: (count, total) {
          add(ChatDetailsDownloadProgress(count, total, event.messageId));
        },
      );

      await Gal.putVideo(savePath);

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

  void _onUploadProgress(
    ChatDetailsUploadProgress event,
    Emitter<ChatDetailsState> emit,
  ) {
    final updatedMessages = state.messages.map((m) {
      if (m.tempMessageId == event.tempMessageId) {
        return m.copyWith(uploadProgress: event.progress);
      }
      return m;
    }).toList();
    
    // Update cache
    if (state.chat?.id != null) {
      _cacheService.updateUploadProgress(state.chat!.id, event.tempMessageId, event.progress);
    }
    
    emit(state.copyWith(messages: updatedMessages));
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
      if (!event.isOtherDeleted) {
        await _chatDetailsRepository.deleteMessage(event.messageId);
      }
      
      final messages = state.messages.where((m) => m.id != event.messageId).toList();
      
      // Update cache
      if (state.chat?.id != null) {
        _cacheService.deleteMessage(state.chat!.id, event.messageId);
      }
      
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
    final typingIds = Set<int>.from(state.typingUserIds);
    if (event.isTyping) {
      typingIds.add(event.userId);
      _restartTypingTimeout(event.userId);
    } else {
      typingIds.remove(event.userId);
      _typingTimers.remove(event.userId)?.cancel();
    }
    emit(state.copyWith(typingUserIds: typingIds));
  }

  void _restartTypingTimeout(int userId) {
    _typingTimers[userId]?.cancel();
    _typingTimers[userId] = Timer(_typingTimeout, () {
      add(ChatDetailsUserTyping(userId, false));
    });
  }

  Set<int> _clearTyping(int userId) {
    if (!state.typingUserIds.contains(userId)) return state.typingUserIds;
    _typingTimers.remove(userId)?.cancel();
    return Set<int>.from(state.typingUserIds)..remove(userId);
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
      final typingUserIds = _clearTyping(event.message.fromUserId);
      if (event.tempMessageId != null) {
        // Replace temp message with real one
        final messages = state.messages.map((m) {
          return m.tempMessageId == event.tempMessageId ? event.message : m;
        }).toList();
        
        // Update cache
        _cacheService.replaceTemporaryMessage(
          event.message.chatId,
          event.tempMessageId!,
          event.message,
        );
        
        emit(state.copyWith(messages: messages, typingUserIds: typingUserIds));
      } else {
        final messages = [event.message, ...state.messages];
        
        // Update cache
        _cacheService.addMessage(event.message.chatId, event.message);
        
        emit(state.copyWith(messages: messages, typingUserIds: typingUserIds));
      }
    }
  }

  Future<void> _onSendMessage(
    ChatDetailsSendMessage event,
    Emitter<ChatDetailsState> emit,
  ) async {
    final chatId = state.chat?.id;
    final currentUser = state.currentUser;
    if (chatId == null || currentUser == null) return;

    final hasFile = event.file != null;
    final hasAttachedMedia = state.attachedMedia != null;
    String? tempMessageId;

    try {
      if (hasFile) {
        // New flow: create temp message and upload in background
        tempMessageId = 'temp_${DateTime.now().millisecondsSinceEpoch}_$chatId';
        final fileType = _getFileType(event.file!.path);

        // Capture reply target before clearing reply state below
        final replyToMessageId = state.replyMessage?.id;

        // Notify peers that media is being sent (shown while uploading)
        await _chatDetailsRepository.sendTyping(chatId, true);

        final fileToUpload = fileType == 'image'
            ? await _normalizeImageOrientation(event.file!)
            : event.file!;

        // Create temporary message
        final tempMessage = Message(
          id: 0,
          chatId: chatId,
          fromUserId: currentUser.id,
          fromPhone: currentUser.phone,
          text: event.text,
          messageType: fileType,
          media: null,
          read: false,
          createdAt: DateTime.now().toString(),
          isEdited: false,
          editCount: 0,
          tempMessageId: tempMessageId,
          isUploading: true,
          localFilePath: fileToUpload.path,
          uploadProgress: 0.0,
          replyTo: state.replyMessage != null ? ReplyTo(
            messageId: state.replyMessage!.id,
            fromUserId: state.replyMessage!.fromUserId,
            fromName: state.replyMessage?.fromName,
            textPreview: state.replyMessage!.text ?? '',
            messageType: state.replyMessage!.messageType,
            media: state.replyMessage!.media,
          ) : null,
        );
        
        final updatedMessages = [tempMessage, ...state.messages];
        
        // Add temp message to cache
        _cacheService.addMessage(chatId, tempMessage);
        
        // Add temp message to UI
        emit(state.copyWith(
          messages: updatedMessages,
          clearReplyMessage: true,
        ));
        
        // Upload file in background
        final media = await _mediaRepository.uploadMedia(
          file: fileToUpload,
          chatId: chatId,
          fileType: fileType,
          onSendProgress: (sent, total) {
            if (total != -1 && tempMessageId != null) {
              final progress = sent / total;
              add(ChatDetailsUploadProgress(tempMessageId, progress));
            }
          },
        );
        
        // Update temp message with media info
        final messagesWithMedia = state.messages.map((m) {
          if (m.tempMessageId == tempMessageId) {
            return m.copyWith(media: media, isUploading: false);
          }
          return m;
        }).toList();
        
        // Update cache with media
        _cacheService.updateMessages(chatId, messagesWithMedia);
        
        emit(state.copyWith(messages: messagesWithMedia));
        
        // Send message via WebSocket
        await _chatDetailsRepository.sendMessage(
          chatId,
          event.text,
          mediaId: media.id,
          messageType: fileType,
          replyToMessageId: replyToMessageId,
          tempMessageId: tempMessageId,
        );
      } else {
        // Old flow for text or already uploaded media
        if (hasAttachedMedia) {
          await _chatDetailsRepository.sendTyping(chatId, true);
        }
        await _chatDetailsRepository.sendMessage(
          chatId,
          event.text,
          mediaId: hasAttachedMedia ? state.attachedMedia!.id : null,
          messageType: hasAttachedMedia ? state.attachedMedia!.type : null,
          replyToMessageId: state.replyMessage?.id,
        );
        emit(state.copyWith(
          clearAttachedMedia: true,
          clearReplyMessage: true,
        ));
      }
    } catch (e) {
      // Remove temp message on error by tempMessageId
      final messages = tempMessageId != null
          ? state.messages.where((m) => m.tempMessageId != tempMessageId).toList()
          : state.messages;
      
      // Remove from cache on error
      if (tempMessageId != null) {
        _cacheService.removeTempMessage(chatId, tempMessageId);
      }
      
      emit(
        state.copyWith(
          status: ChatDetailsStatus.failure,
          errorMessage: e.toString(),
          messages: messages,
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

  Future<File> _normalizeImageOrientation(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return file;
      final oriented = img.bakeOrientation(decoded);
      final tempDir = await getTemporaryDirectory();
      final fileName = file.path.split('/').last;
      final outFile = File('${tempDir.path}/oriented_$fileName');
      await outFile.writeAsBytes(img.encodeJpg(oriented, quality: 92));
      return outFile;
    } catch (_) {
      return file;
    }
  }

  Future<void> _onLoad(
    ChatDetailsLoad event,
    Emitter<ChatDetailsState> emit,
  ) async {
    // Check cache first
    final cachedData = _cacheService.getChatCache(event.chatId);
    
    if (cachedData != null) {
      // Load from cache immediately
      emit(
        state.copyWith(
          status: ChatDetailsStatus.success,
          chat: cachedData.chat,
          members: cachedData.members,
          messages: cachedData.messages,
          hasReachedMax: cachedData.hasReachedMax,
          currentUser: event.user,
        ),
      );
    } else {
      emit(state.copyWith(status: ChatDetailsStatus.loading));
    }

    try {
      // Load fresh data from server
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

      final reversedMessages = messages.reversed.toList();
      final hasReachedMax = messages.length < _limit;

      // Preserve temporary messages (uploading files)
      final tempMessages = state.messages.where((m) {
        return m.tempMessageId != null && (m.isUploading || m.id == 0);
      }).toList();

      // Merge temp messages with server messages
      final mergedMessages = _mergeMessages(reversedMessages, tempMessages);

      // Update cache
      _cacheService.setChatCache(
        event.chatId,
        ChatCacheData(
          messages: mergedMessages,
          chat: chatDetails.chat,
          members: chatDetails.members,
          hasReachedMax: hasReachedMax,
        ),
      );

      emit(
        state.copyWith(
          status: ChatDetailsStatus.success,
          chat: chatDetails.chat,
          members: chatDetails.members,
          messages: mergedMessages,
          hasReachedMax: hasReachedMax,
          currentUser: event.user,
        ),
      );
    } catch (e) {
      // If we have cache and network failed, keep cached data
      if (cachedData == null) {
        emit(
          state.copyWith(
            status: ChatDetailsStatus.failure,
            errorMessage: e.toString(),
          ),
        );
      }
    }
  }

  List<Message> _mergeMessages(List<Message> serverMessages, List<Message> tempMessages) {
    if (tempMessages.isEmpty) return serverMessages;
    
    // Add temp messages at the beginning (they are new)
    final result = [...tempMessages];
    
    // Add server messages that are not already represented by temp messages
    for (final serverMsg in serverMessages) {
      final alreadyExists = tempMessages.any((temp) => 
        temp.tempMessageId != null && serverMsg.id == temp.id
      );
      if (!alreadyExists) {
        result.add(serverMsg);
      }
    }
    
    // Sort by creation time (newest first)
    result.sort((a, b) {
      final aTime = DateTime.tryParse(a.createdAt) ?? DateTime.now();
      final bTime = DateTime.tryParse(b.createdAt) ?? DateTime.now();
      return bTime.compareTo(aTime);
    });
    
    return result;
  }

  Future<void> _onLoadMore(
    ChatDetailsLoadMore event,
    Emitter<ChatDetailsState> emit,
  ) async {
    if (state.hasReachedMax) return;
    if (state.status == ChatDetailsStatus.loading) return;

    emit(state.copyWith(status: ChatDetailsStatus.loading));
    try {
      // Find last real message (not temporary) for pagination
      final realMessages = state.messages.where((m) => m.id > 0 && m.tempMessageId == null).toList();
      final lastMessageId = realMessages.isNotEmpty ? realMessages.last.id : null;
      
      final messages = await _chatDetailsRepository.getMessages(
        event.chatId,
        limit: _limit,
        toMessageId: lastMessageId,
      );
      
      final updatedMessages = List.of(state.messages)..addAll(messages.reversed);
      final hasReachedMax = messages.length < _limit;
      
      // Update cache
      _cacheService.setChatCache(
        event.chatId,
        ChatCacheData(
          messages: updatedMessages,
          chat: state.chat,
          members: state.members,
          hasReachedMax: hasReachedMax,
        ),
      );
      
      emit(
        state.copyWith(
          status: ChatDetailsStatus.success,
          messages: updatedMessages,
          hasReachedMax: hasReachedMax,
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
      
      // Update cache
      _cacheService.updateChatAvatar(state.chat!.id, avatarUrl);
      
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
    // Update cache
    if (state.chat?.id != null) {
      _cacheService.updateChatAvatar(state.chat!.id, event.avatarUrl);
    }
    
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
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }
    _typingTimers.clear();
    _wsSubscription?.cancel();
    return super.close();
  }
}
