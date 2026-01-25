part of 'connectivity_bloc.dart';

sealed class ConnectivityEvent {
  const ConnectivityEvent();
}

class ConnectivityStarted extends ConnectivityEvent {
  const ConnectivityStarted();
}

class _ConnectivityChanged extends ConnectivityEvent {
  final List<ConnectivityResult> results;
  const _ConnectivityChanged(this.results);
}
