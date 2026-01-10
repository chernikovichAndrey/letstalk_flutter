part of 'contacts_bloc.dart';

abstract class ContactsState {}

class ContactsInitial extends ContactsState {}

class ContactsLoading extends ContactsState {}

class ContactsLoaded extends ContactsState {
  final List<Contact> contacts;
  final List<Contact> allContacts;
  final String query;

  ContactsLoaded(this.allContacts, {List<Contact>? contacts, this.query = ''})
      : contacts = contacts ?? allContacts;
}

class ContactsError extends ContactsState {
  final String message;

  ContactsError(this.message);
}
