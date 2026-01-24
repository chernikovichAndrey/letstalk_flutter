import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:lets_talk/feature/calls_history/data/model/call_history_model.dart';
import 'package:lets_talk/feature/calls_history/domain/repository/calls_history_repository.dart';

part 'calls_history_event.dart';
part 'calls_history_state.dart';

@injectable
class CallsHistoryBloc extends Bloc<CallsHistoryEvent, CallsHistoryState> {
  final CallsHistoryRepository callsRepository;

  CallsHistoryBloc(this.callsRepository) : super(CallsHistoryInitial()) {
    on<LoadHistoryCalls>((event, emit) async {
      emit(CallsHistoryLoading());
      try {
        final calls = await callsRepository.getCalls();
        emit(CallsHistoryLoaded(calls));
      } catch (e) {
        emit(CallsHistoryError(e.toString()));
      }
    });

    on<RefreshHistoryCalls>((event, emit) async {
      try {
        final calls = await callsRepository.getCalls();
        emit(CallsHistoryLoaded(calls));
      } catch (e) {
        emit(CallsHistoryError(e.toString()));
      } finally {
        event.completer?.complete();
      }
    });

    on<DeleteHistoryCall>((event, emit) async {
      final currentState = state;
      if (currentState is CallsHistoryLoaded) {
        try {
          await callsRepository.deleteCall(event.callId);
          // Optimistically remove the call from the list
          final updatedCalls = currentState.calls
              .where((call) => call.id != event.callId)
              .toList();
          emit(currentState.copyWith(calls: updatedCalls));
        } catch (e) {
          emit(CallsHistoryError(e.toString()));
          // Reload calls to revert to correct state
          add(LoadHistoryCalls());
        }
      }
    });

    on<CallsHistoryToggleSelectionMode>((event, emit) {
      final currentState = state;
      if (currentState is CallsHistoryLoaded) {
        emit(currentState.copyWith(
          isSelectionMode: !currentState.isSelectionMode,
          selectedCallIds: {},
        ));
      }
    });

    on<CallsHistoryToggleCallSelection>((event, emit) {
      final currentState = state;
      if (currentState is CallsHistoryLoaded && currentState.isSelectionMode) {
        final updatedSelectedIds = Set<int>.from(currentState.selectedCallIds);
        if (updatedSelectedIds.contains(event.callId)) {
          updatedSelectedIds.remove(event.callId);
        } else {
          updatedSelectedIds.add(event.callId);
        }
        emit(currentState.copyWith(selectedCallIds: updatedSelectedIds));
      }
    });

    on<CallsHistoryDeleteSelected>((event, emit) async {
      final currentState = state;
      if (currentState is CallsHistoryLoaded &&
          currentState.selectedCallIds.isNotEmpty) {
        final selectedIds = currentState.selectedCallIds.toList();
        emit(CallsHistoryActionInProgress());
        try {
          for (final id in selectedIds) {
            await callsRepository.deleteCall(id);
          }
          final calls = await callsRepository.getCalls();
          emit(CallsHistoryLoaded(calls));
        } catch (e) {
          emit(CallsHistoryError(e.toString()));
          add(LoadHistoryCalls());
        }
      }
    });
  }
}
