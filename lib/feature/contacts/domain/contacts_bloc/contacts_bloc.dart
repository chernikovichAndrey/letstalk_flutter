import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';
import 'package:lets_talk/feature/contacts/domain/repository/contacts_repository.dart';

part 'contacts_event.dart';
part 'contacts_state.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final ContactsRepository _contactsRepository;

  ContactsBloc(this._contactsRepository) : super(ContactsInitial()) {
    on<ContactsLoad>(_onLoad);
    on<ContactsRefresh>(_onRefresh);
    on<ContactsSearch>(_onSearch);
  }

  Future<void> _onLoad(ContactsLoad event, Emitter<ContactsState> emit) async {
    emit(ContactsLoading());
    try {
      final contacts = await _contactsRepository.getContacts();
      emit(ContactsLoaded(contacts));
    } catch (e) {
      emit(ContactsError(e.toString()));
    }
  }

  Future<void> _onRefresh(ContactsRefresh event, Emitter<ContactsState> emit) async {
    final currentState = state;
    String currentQuery = '';
    if (currentState is ContactsLoaded) {
      currentQuery = currentState.query;
    }

    try {
      final contacts = await _contactsRepository.getContacts();
      if (currentQuery.isNotEmpty) {
        final query = currentQuery.toLowerCase();
        final filteredContacts = contacts.where((contact) {
          final name = contact.fullName.toLowerCase();
          final phone = contact.phone.toLowerCase();
          return name.contains(query) || phone.contains(query);
        }).toList();
        emit(ContactsLoaded(contacts, contacts: filteredContacts, query: currentQuery));
      } else {
        emit(ContactsLoaded(contacts));
      }
    } catch (e) {
      emit(ContactsError(e.toString()));
    } finally {
      event.completer?.complete();
    }
  }

  void _onSearch(ContactsSearch event, Emitter<ContactsState> emit) {
    final state = this.state;
    if (state is ContactsLoaded) {
      final query = event.query.toLowerCase();
      final filteredContacts = state.allContacts.where((contact) {
        final name = contact.fullName.toLowerCase();
        final phone = contact.phone.toLowerCase();
        return name.contains(query) || phone.contains(query);
      }).toList();
      emit(ContactsLoaded(state.allContacts, contacts: filteredContacts, query: event.query));
    }
  }
}
