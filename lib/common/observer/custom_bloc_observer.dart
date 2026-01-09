import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class CustomBlocObserver extends BlocObserver {
  final _logger = Logger();

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _logger.e(error);
  }
}
