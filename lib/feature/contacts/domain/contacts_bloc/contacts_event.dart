part of 'contacts_bloc.dart';

abstract class ContactsEvent {}

class ContactsLoad extends ContactsEvent {}

class ContactsRefresh extends ContactsEvent {
  final Completer? completer;

  ContactsRefresh({this.completer});
}
