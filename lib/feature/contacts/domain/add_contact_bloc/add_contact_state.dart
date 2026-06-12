part of 'add_contact_bloc.dart';

abstract class AddContactState {}

class AddContactInitial extends AddContactState {}

class AddContactInProgress extends AddContactState {}

class AddContactSuccess extends AddContactState {}

class AddContactAlreadyExists extends AddContactState {}

class AddContactError extends AddContactState {
  final String message;

  AddContactError(this.message);
}
