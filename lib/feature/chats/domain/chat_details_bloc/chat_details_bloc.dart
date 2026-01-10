import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/domain/repository/chats_repository.dart';
import 'package:lets_talk/feature/settings/data/model/user_model.dart';
import 'package:lets_talk/feature/settings/data/repository/profile_repository.dart';

part 'chat_details_event.dart';

part 'chat_details_state.dart';

class ChatDetailsBloc extends Bloc<ChatDetailsEvent, ChatDetailsState> {
  final ChatsRepository _chatsRepository;
  final ProfileRepository _profileRepository;
  static const int _limit = 20;

  ChatDetailsBloc(this._chatsRepository, this._profileRepository)
    : super(const ChatDetailsState()) {
    on<ChatDetailsLoad>(_onLoad);
    on<ChatDetailsLoadMore>(_onLoadMore);
  }

  Future<void> _onLoad(
    ChatDetailsLoad event,
    Emitter<ChatDetailsState> emit,
  ) async {
    emit(state.copyWith(status: ChatDetailsStatus.loading));
    try {
      final user = await _profileRepository.getProfile();
      final chatDetails = await _chatsRepository.getChatDetails(event.chatId);
      final messages = await _chatsRepository.getMessages(
        event.chatId,
        limit: _limit,
      );

      emit(
        state.copyWith(
          status: ChatDetailsStatus.success,
          chat: chatDetails.chat,
          members: chatDetails.members,
          messages: messages.reversed.toList(),
          hasReachedMax: messages.length < _limit,
          currentUser: user,
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
      final messages = await _chatsRepository.getMessages(
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
}
