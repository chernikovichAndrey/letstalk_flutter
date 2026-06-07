import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:lets_talk/common/service/phone_contacts_service.dart';
import 'package:lets_talk/feature/chats/domain/repository/chats_repository.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';
import 'package:lets_talk/feature/contacts/domain/repository/contacts_repository.dart';

part 'contacts_event.dart';
part 'contacts_state.dart';

@singleton
class ContactsBloc extends Bloc<ContactsEvent, ContactsState> with WidgetsBindingObserver {
  final ContactsRepository _contactsRepository;
  final ChatsRepository _chatsRepository;
  final PhoneContactsService _phoneContactsService;

  ContactsBloc(
    this._contactsRepository,
    this._chatsRepository,
    this._phoneContactsService,
  )  : super(ContactsInitial()) {
    on<ResetContactsBloc>(_onResetContactsBloc);
    on<ContactsLoad>(_onLoad);
    on<ContactsRefresh>(_onRefresh);
    on<ContactsSearch>(_onSearch);
    on<ContactsToggleSelectionMode>(_onToggleSelectionMode);
    on<ContactsToggleContactSelection>(_onToggleContactSelection);
    on<ContactsDeleteSelected>(_onDeleteSelected);
    on<ContactsSyncPhoneContacts>(_onSyncPhoneContacts);
    on<ContactsCreateChat>(_onCreateChat);

    _phoneContactsService.addListener(_onPhoneContactsChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  void _onPhoneContactsChanged() {
    add(ContactsSyncPhoneContacts());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      add(ContactsSyncPhoneContacts());
    }
  }

  @override
  Future<void> close() {
    _phoneContactsService.removeListener(_onPhoneContactsChanged);
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
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

  Future<void> _onSyncPhoneContacts(
    ContactsSyncPhoneContacts event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      final phoneContacts = await _phoneContactsService.getPhoneContacts();

      if (phoneContacts.isNotEmpty) {
        await _contactsRepository.uploadPhoneContacts(phoneContacts);
      }

      final contacts = await _contactsRepository.getContacts();
      emit(ContactsLoaded(contacts));
    } catch (e) {
      emit(ContactsError(e.toString()));
    }
  }

  Future<void> _onRefresh(ContactsRefresh event, Emitter<ContactsState> emit) async {
    final currentState = state;
    String currentQuery = '';
    bool isSelectionMode = false;
    Set<int> selectedIds = {};

    if (currentState is ContactsLoaded) {
      currentQuery = currentState.query;
      isSelectionMode = currentState.isSelectionMode;
      selectedIds = currentState.selectedContactIds;
    }

    try {
      final phoneContacts = await _phoneContactsService.getPhoneContacts();
      if (phoneContacts.isNotEmpty) {
        await _contactsRepository.uploadPhoneContacts(phoneContacts);
      }

      final contacts = await _contactsRepository.getContacts();
      if (currentQuery.isNotEmpty) {
        final query = currentQuery.toLowerCase();
        final filteredContacts = contacts.where((contact) {
          final name = contact.fullName.toLowerCase();
          final phone = contact.phone.toLowerCase();
          return name.contains(query) || phone.contains(query);
        }).toList();
        emit(ContactsLoaded(
          contacts,
          contacts: filteredContacts,
          query: currentQuery,
          isSelectionMode: isSelectionMode,
          selectedContactIds: selectedIds,
        ));
      } else {
        emit(ContactsLoaded(
          contacts,
          isSelectionMode: isSelectionMode,
          selectedContactIds: selectedIds,
        ));
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
      emit(state.copyWith(
        contacts: filteredContacts,
        query: event.query,
      ));
    }
  }

  void _onToggleSelectionMode(
    ContactsToggleSelectionMode event,
    Emitter<ContactsState> emit,
  ) {
    final state = this.state;
    if (state is ContactsLoaded) {
      emit(state.copyWith(
        isSelectionMode: !state.isSelectionMode,
        selectedContactIds: {},
      ));
    }
  }

  void _onToggleContactSelection(
    ContactsToggleContactSelection event,
    Emitter<ContactsState> emit,
  ) {
    final state = this.state;
    if (state is ContactsLoaded && state.isSelectionMode) {
      final updatedSelectedIds = Set<int>.from(state.selectedContactIds);
      if (updatedSelectedIds.contains(event.contactId)) {
        updatedSelectedIds.remove(event.contactId);
      } else {
        updatedSelectedIds.add(event.contactId);
      }
      emit(state.copyWith(selectedContactIds: updatedSelectedIds));
    }
  }

  Future<void> _onDeleteSelected(
    ContactsDeleteSelected event,
    Emitter<ContactsState> emit,
  ) async {
    final state = this.state;
    if (state is ContactsLoaded && state.selectedContactIds.isNotEmpty) {
      final selectedIds = state.selectedContactIds.toList();
      final contactsToDelete = state.allContacts
          .where((c) => c.id != null && selectedIds.contains(c.id))
          .toList();
      
      emit(ContactsActionInProgress());
      try {
        for (final contact in contactsToDelete) {
          await _contactsRepository.deleteContacts(contact.id!);
          await _phoneContactsService.addToExclusionList(contact.phone);
        } // After deletion, reload contacts and exit selection mode
        final contacts = await _contactsRepository.getContacts();
        emit(ContactsLoaded(contacts));
      } catch (e) {
        emit(ContactsError(e.toString()));
      }
    }
  }

  Future<void> _onCreateChat(ContactsCreateChat event,
      Emitter<ContactsState> emit,) async {
    final state = this.state;
    if (state is ContactsLoaded) {
      emit(ContactsCreateChatInProgress(state));
      try {
        final response = await _chatsRepository.createPrivateChat(event.userId);
        emit(ContactsChatCreated(response.chat.id));
        emit(state);
      } catch (e) {
        emit(ContactsError(e.toString()));
      }
    }
  }

  void _onResetContactsBloc(ResetContactsBloc event, Emitter<ContactsState> emit) {
    emit(ContactsInitial());
  }
}
