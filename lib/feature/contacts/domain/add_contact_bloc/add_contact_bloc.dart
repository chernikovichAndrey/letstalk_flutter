import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';
import 'package:lets_talk/feature/contacts/domain/repository/add_contact_repository.dart';

part 'add_contact_event.dart';
part 'add_contact_state.dart';

@injectable
class AddContactBloc extends Bloc<AddContactEvent, AddContactState> {
  final AddContactRepository _addContactRepository;

  AddContactBloc(this._addContactRepository) : super(AddContactInitial()) {
    on<AddContactSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    AddContactSubmitted event,
    Emitter<AddContactState> emit,
  ) async {
    emit(AddContactInProgress());
    try {
      await _addContactRepository.addContacts(event.contact);
      emit(AddContactSuccess());
    } catch (e) {
      emit(AddContactError(e.toString()));
    }
  }
}
