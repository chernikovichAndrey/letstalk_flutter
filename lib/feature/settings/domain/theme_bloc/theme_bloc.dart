import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:lets_talk/feature/settings/data/repository/theme_repository.dart';
import 'package:lets_talk/feature/settings/domain/theme_bloc/theme_event.dart';
import 'package:lets_talk/feature/settings/domain/theme_bloc/theme_state.dart';

@singleton
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeRepository _repository;

  ThemeBloc(this._repository)
    : super(const ThemeState(mode: ThemeMode.system)) {
    on<ThemeChanged>(_onThemeChanged);
    on<LoadSavedTheme>(_onLoadSavedTheme);
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(mode: event.mode));
    await _repository.saveThemeMode(event.mode);
  }

  Future<void> _onLoadSavedTheme(
    LoadSavedTheme event,
    Emitter<ThemeState> emit,
  ) async {
    final saved = await _repository.getThemeMode();

    if (saved != null) {
      emit(state.copyWith(mode: saved));
    }
  }
}
