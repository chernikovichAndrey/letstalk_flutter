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
    try {
      final contacts = await _contactsRepository.getContacts();
      emit(ContactsLoaded(contacts));
    } catch (e) {
      emit(ContactsError(e.toString()));
    } finally {
      event.completer?.complete();
    }
  }
}
