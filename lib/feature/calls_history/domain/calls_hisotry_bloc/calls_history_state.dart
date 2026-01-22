part of 'calls_history_bloc.dart';

@immutable
sealed class CallsHistoryState {}

final class CallsHistoryInitial extends CallsHistoryState {}

final class CallsHistoryLoading extends CallsHistoryState {}

final class CallsHistoryLoaded extends CallsHistoryState {
  final List<CallHistory> calls;
  final bool isSelectionMode;
  final Set<int> selectedCallIds;

  CallsHistoryLoaded(
    this.calls, {
    this.isSelectionMode = false,
    this.selectedCallIds = const {},
  });

  CallsHistoryLoaded copyWith({
    List<CallHistory>? calls,
    bool? isSelectionMode,
    Set<int>? selectedCallIds,
  }) {
    return CallsHistoryLoaded(
      calls ?? this.calls,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedCallIds: selectedCallIds ?? this.selectedCallIds,
    );
  }
}

final class CallsHistoryActionInProgress extends CallsHistoryState {}

final class CallsHistoryError extends CallsHistoryState {
  final String message;

  CallsHistoryError(this.message);
}
