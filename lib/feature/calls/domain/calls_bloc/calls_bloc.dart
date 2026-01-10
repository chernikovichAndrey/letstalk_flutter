import 'package:bloc/bloc.dart';
import 'package:lets_talk/feature/calls/data/model/call_model.dart';
import 'package:lets_talk/feature/calls/domain/repository/calls_repository.dart';
import 'package:meta/meta.dart';

part 'calls_event.dart';
part 'calls_state.dart';

class CallsBloc extends Bloc<CallsEvent, CallsState> {
  final CallsRepository callsRepository;

  CallsBloc(this.callsRepository) : super(CallsInitial()) {
    on<LoadCalls>((event, emit) async {
      emit(CallsLoading());
      try {
        final calls = await callsRepository.getCalls();
        emit(CallsLoaded(calls));
      } catch (e) {
        emit(CallsError(e.toString()));
      }
    });

    on<DeleteCall>((event, emit) async {
      final currentState = state;
      if (currentState is CallsLoaded) {
        try {
          await callsRepository.deleteCall(event.callId);
          // Optimistically remove the call from the list
          final updatedCalls = currentState.calls
              .where((call) => call.id != event.callId)
              .toList();
          emit(CallsLoaded(updatedCalls));
        } catch (e) {
          emit(CallsError(e.toString()));
          // Reload calls to revert to correct state
          add(LoadCalls());
        }
      }
    });
  }
}
