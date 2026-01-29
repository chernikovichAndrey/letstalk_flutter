import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:lets_talk/feature/settings/data/repository/locale_repository.dart';
import 'package:lets_talk/feature/settings/domain/locale_bloc/locale_event.dart';
import 'package:lets_talk/feature/settings/domain/locale_bloc/locale_state.dart';

@singleton
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  final LocaleRepository _repository;

  LocaleBloc(this._repository) : super(LocaleState(locale: _getInitialLocale())) {
    on<LocaleChanged>(_onLocaleChanged);
    on<LoadSavedLocale>(_onLoadSavedLocale);
  }

  static Locale _getInitialLocale() {
    final supportedLanguages = ['en', 'ru', 'kk'];
    final deviceLocale = ui.PlatformDispatcher.instance.locale;
    final deviceLanguageCode = deviceLocale.languageCode;

    if (supportedLanguages.contains(deviceLanguageCode)) {
      return Locale(deviceLanguageCode);
    }

    return const Locale('ru');
  }

  Future<void> _onLocaleChanged(LocaleChanged event, Emitter<LocaleState> emit) async {
    emit(state.copyWith(locale: event.locale));
    await _repository.saveLocale(event.locale);
  }

  Future<void> _onLoadSavedLocale(LoadSavedLocale event, Emitter<LocaleState> emit) async {
    final savedLocale = await _repository.getLocale();
    
    if (savedLocale != null) {
      emit(state.copyWith(locale: savedLocale));
    }
  }
}
