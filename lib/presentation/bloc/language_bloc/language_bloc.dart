import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_event.dart';
import 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(const LanguageState(Locale('en'))) {
    on<ChangeLanguage>(_onChangeLanguage);
    on<LoadSavedLanguage>(_onLoadSavedLanguage);
  }

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', event.locale.languageCode);
    emit(LanguageState(event.locale));
  }

  Future<void> _onLoadSavedLanguage(
    LoadSavedLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code');
    if (languageCode != null) {
      emit(LanguageState(Locale(languageCode)));
    }
  }
}
