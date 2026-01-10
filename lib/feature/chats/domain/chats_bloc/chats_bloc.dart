import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/chats/domain/repository/chats_repository.dart';

part 'chats_event.dart';
part 'chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final ChatsRepository _chatsRepository;

  ChatsBloc(this._chatsRepository) : super(ChatsInitial()) {
    on<ChatsLoad>(_onLoad);
    on<ChatsRefresh>(_onRefresh);
    on<ChatsSearch>(_onSearch);
    on<ChatUpdated>(_onChatUpdated);
  }

  Future<void> _onChatUpdated(ChatUpdated event, Emitter<ChatsState> emit) async {
    final currentState = state;
    if (currentState is ChatsLoaded) {
      try {
        final chatDetails = await _chatsRepository.getChatDetails(event.chatId);
        final updatedChats = currentState.chats.map((chat) {
          return chat.id == event.chatId ? chatDetails.chat : chat;
        }).toList();
        emit(ChatsLoaded(updatedChats));
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
