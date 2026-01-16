part of 'add_contact_bloc.dart';

abstract class AddContactEvent {}

class AddContactSubmitted extends AddContactEvent {
  final Contact contact;

  AddContactSubmitted(this.contact);
}
