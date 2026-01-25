part of 'navigation_bloc.dart';

abstract class NavigationEvent {}

class NavigationInitEvent extends NavigationEvent{}

class NavigationMessageReceived extends NavigationEvent {}

class NavigationMessageRead extends NavigationEvent {}

class NavigationCallMissed extends NavigationEvent {}

class NavigationUpdateUnreadCount extends NavigationEvent {
  final int count;

  NavigationUpdateUnreadCount(this.count);
}

class NavigationReset extends NavigationEvent {}
