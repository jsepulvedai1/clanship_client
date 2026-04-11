import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SettingsRepository {
  static const String _settingsBoxName = 'settings_box';
  static const String _themeModeKey = 'theme_mode';
  static const String _localeKey = 'locale';

  /// Initializes Hive and opens the settings box.
  /// Should be called during the application setup in main.dart.
  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_settingsBoxName);
  }

  Box get _box => Hive.box(_settingsBoxName);

  /// Retrieves the saved ThemeMode. Defaults to [ThemeMode.system].
  ThemeMode getThemeMode() {
    final mode = _box.get(_themeModeKey, defaultValue: 'system');
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Persists the selected ThemeMode.
  Future<void> saveThemeMode(ThemeMode mode) async {
    String modeStr;
    switch (mode) {
      case ThemeMode.light:
        modeStr = 'light';
        break;
      case ThemeMode.dark:
        modeStr = 'dark';
        break;
      default:
        modeStr = 'system';
    }
    await _box.put(_themeModeKey, modeStr);
  }

  /// Retrieves the saved Locale. Defaults to Spanish ('es').
  Locale getLocale() {
    final languageCode = _box.get(_localeKey, defaultValue: 'es');
    return Locale(languageCode);
  }

  /// Persists the selected Locale.
  Future<void> saveLocale(Locale locale) async {
    await _box.put(_localeKey, locale.languageCode);
  }
}
