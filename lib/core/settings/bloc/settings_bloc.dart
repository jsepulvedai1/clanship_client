import 'package:clanship_cliente/core/settings/bloc/settings_event.dart';
import 'package:clanship_cliente/core/settings/bloc/settings_state.dart';
import 'package:clanship_cliente/core/settings/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repository;

  SettingsBloc(this._repository)
      : super(const SettingsState(
          themeMode: ThemeMode.system,
          locale: Locale('es'),
        )) {
    on<LoadSettings>((event, emit) async {
      final mode = _repository.getThemeMode();
      final locale = _repository.getLocale();
      emit(SettingsState(themeMode: mode, locale: locale));
    });

    on<UpdateTheme>((event, emit) async {
      await _repository.saveThemeMode(event.themeMode);
      emit(state.copyWith(themeMode: event.themeMode));
    });

    on<UpdateLocale>((event, emit) async {
      await _repository.saveLocale(event.locale);
      emit(state.copyWith(locale: event.locale));
    });
  }
}
