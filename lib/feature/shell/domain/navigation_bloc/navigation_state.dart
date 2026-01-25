part of 'navigation_bloc.dart';

class NavigationState {
  final int unreadChatsCount;
  final int missedCallsCount;

  NavigationState({
    required this.unreadChatsCount,
    required this.missedCallsCount,
  });

  factory NavigationState.initial() {
    return NavigationState(
      unreadChatsCount: 0,
      missedCallsCount: 0,
    );
  }

  NavigationState copyWith({
    int? unreadChatsCount,
    int? missedCallsCount,
  }) {
    return NavigationState(
      unreadChatsCount: unreadChatsCount ?? this.unreadChatsCount,
      missedCallsCount: missedCallsCount ?? this.missedCallsCount,
    );
  }
}
