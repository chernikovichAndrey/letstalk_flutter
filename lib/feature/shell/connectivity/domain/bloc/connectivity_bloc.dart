import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

@singleton
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  ConnectivityBloc()
      : _connectivity = Connectivity(),
        super(const ConnectivityInitial()) {
    on<ConnectivityStarted>(_onConnectivityStarted);
    on<_ConnectivityChanged>(_onConnectivityChanged);
  }

  @postConstruct
  void init() {
    add(const ConnectivityStarted());
  }

  Future<void> _onConnectivityStarted(
    ConnectivityStarted event,
    Emitter<ConnectivityState> emit,
  ) async {
    try {
      final results = await _connectivity.checkConnectivity();
      emit(ConnectivitySuccess(results));
    } catch (e) {
      emit(ConnectivityFailure(e.toString()));
    }

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((results) {
      add(_ConnectivityChanged(results));
    });
  }

  void _onConnectivityChanged(
    _ConnectivityChanged event,
    Emitter<ConnectivityState> emit,
  ) {
    emit(ConnectivitySuccess(event.results));
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
