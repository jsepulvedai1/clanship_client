import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

/// Event to load settings from persistent storage.
class LoadSettings extends SettingsEvent {}

/// Event to update the application theme.
class UpdateTheme extends SettingsEvent {
  final ThemeMode themeMode;
  const UpdateTheme(this.themeMode);
  @override
  List<Object?> get props => [themeMode];
}

/// Event to update the application language.
class UpdateLocale extends SettingsEvent {
  final Locale locale;
  const UpdateLocale(this.locale);
  @override
  List<Object?> get props => [locale];
}
