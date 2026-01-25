part of 'connectivity_bloc.dart';

sealed class ConnectivityState {
  const ConnectivityState();
}

class ConnectivityInitial extends ConnectivityState {
  const ConnectivityInitial();
}

class ConnectivitySuccess extends ConnectivityState {
  final List<ConnectivityResult> results;
  const ConnectivitySuccess(this.results);
}

class ConnectivityFailure extends ConnectivityState {
  final String error;
  const ConnectivityFailure(this.error);
}
