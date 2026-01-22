part of 'contacts_bloc.dart';

abstract class ContactsState {}

class ContactsInitial extends ContactsState {}

class ContactsLoading extends ContactsState {}

class ContactsLoaded extends ContactsState {
  final List<Contact> contacts;
  final List<Contact> allContacts;
  final String query;
  final bool isSelectionMode;
  final Set<int> selectedContactIds;

  ContactsLoaded(
    this.allContacts, {
    List<Contact>? contacts,
    this.query = '',
    this.isSelectionMode = false,
    this.selectedContactIds = const {},
  }) : contacts = contacts ?? allContacts;

  ContactsLoaded copyWith({
    List<Contact>? allContacts,
    List<Contact>? contacts,
    String? query,
    bool? isSelectionMode,
    Set<int>? selectedContactIds,
  }) {
    return ContactsLoaded(
      allContacts ?? this.allContacts,
      contacts: contacts ?? this.contacts,
      query: query ?? this.query,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedContactIds: selectedContactIds ?? this.selectedContactIds,
    );
  }
}

class ContactsError extends ContactsState {
  final String message;

  ContactsError(this.message);
}

class ContactsActionInProgress extends ContactsState {}

class ContactsCreateChatInProgress extends ContactsState {
  final ContactsLoaded state;

  ContactsCreateChatInProgress(this.state);
}

class ContactsChatCreated extends ContactsState {
  final int chatId;

  ContactsChatCreated(this.chatId);
}

class ContactsActionSuccess extends ContactsState {}

class ContactsSyncingPhoneContacts extends ContactsState {
  final double progress;

  ContactsSyncingPhoneContacts(this.progress);
}
