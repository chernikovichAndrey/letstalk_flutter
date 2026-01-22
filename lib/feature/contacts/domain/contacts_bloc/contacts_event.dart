part of 'contacts_bloc.dart';

abstract class ContactsEvent {}

class ContactsLoad extends ContactsEvent {}

class ContactsRefresh extends ContactsEvent {
  final Completer? completer;

  ContactsRefresh({this.completer});
}

class ContactsSearch extends ContactsEvent {
  final String query;

  ContactsSearch(this.query);
}

class ContactsToggleSelectionMode extends ContactsEvent {}

class ContactsToggleContactSelection extends ContactsEvent {
  final int contactId;

  ContactsToggleContactSelection(this.contactId);
}

class ContactsDeleteSelected extends ContactsEvent {}

class ContactsCreateChat extends ContactsEvent {
  final int userId;

  ContactsCreateChat(this.userId);
}

class ContactsSyncPhoneContacts extends ContactsEvent {}

