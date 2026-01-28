import 'package:injectable/injectable.dart';
import 'package:lets_talk/feature/call/domain/bloc/call_bloc.dart';
import 'package:lets_talk/feature/chats/domain/chats_bloc/chats_bloc.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';
import 'package:lets_talk/feature/shell/domain/navigation_bloc/navigation_bloc.dart';

@singleton
class ResetService {
  final ChatsBloc _chatsBloc;
  final ContactsBloc _contactsBloc;
  final ProfileBloc _profileBloc;
  final CallBloc _callBloc;
  final NavigationBloc _navigationBloc;

  ResetService(
    this._chatsBloc,
    this._contactsBloc,
    this._profileBloc,
    this._callBloc,
    this._navigationBloc,
  );

  Future<void> resetAll() async {
    _chatsBloc.add(ResetChatsBloc());
    _contactsBloc.add(ResetContactsBloc());
    _profileBloc.add(ResetProfileBloc());
    _callBloc.add(ResetCallBloc());
    _navigationBloc.add(NavigationReset());
  }
}
