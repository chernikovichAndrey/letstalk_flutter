part of 'chats_bloc.dart';

abstract class ChatsEvent {}

class ChatsLoad extends ChatsEvent {}

class ChatsRefresh extends ChatsEvent {
  final Completer? completer;

  ChatsRefresh([this.completer]);
}
