import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:lets_talk/common/service/phone_contacts_service.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';
import 'package:lets_talk/feature/contacts/domain/repository/add_contact_repository.dart';

part 'add_contact_event.dart';
part 'add_contact_state.dart';

@injectable
class AddContactBloc extends Bloc<AddContactEvent, AddContactState> {
  final AddContactRepository _addContactRepository;
  final PhoneContactsService _phoneContactsService;

  AddContactBloc(
    this._addContactRepository,
    this._phoneContactsService,
  ) : super(AddContactInitial()) {
    on<AddContactSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    AddContactSubmitted event,
    Emitter<AddContactState> emit,
  ) async {
    emit(AddContactInProgress());
    try {
      await _addContactRepository.addContacts(event.contact);
      await _phoneContactsService.removeFromExclusionList(event.contact.phone);
      emit(AddContactSuccess());
    } catch (e) {
      if ((e as DioException).response?.statusCode == 422) {
        emit(AddContactAlreadyExists());
      } else {
        emit(AddContactError(e.toString()));
      }
    }
  }
}
