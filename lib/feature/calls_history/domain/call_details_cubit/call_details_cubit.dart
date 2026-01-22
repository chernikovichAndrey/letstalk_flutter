import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/feature/calls_history/data/model/call_history_model.dart';
import 'package:lets_talk/feature/calls_history/domain/repository/calls_history_repository.dart';

part 'call_details_state.dart';

class CallDetailsCubit extends Cubit<CallDetailsState> {
  final CallsHistoryRepository repository;

  CallDetailsCubit(this.repository) : super(CallDetailsInitial());

  Future<void> loadCallDetails(int id) async {
    emit(CallDetailsLoading());
    try {
      final call = await repository.getCallDetails(id);
      emit(CallDetailsLoaded(call));
    } catch (e) {
      emit(CallDetailsError(e.toString()));
    }
  }
}
