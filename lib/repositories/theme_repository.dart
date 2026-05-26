import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeRepository {
  final FlutterSecureStorage _storage;

  ThemeRepository(this._storage);

  static const String _themeModeKey = 'theme_mode';

  Future<ThemeMode> getThemeMode() async {
    final value = await _storage.read(key: _themeModeKey);
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.light,
    };
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final value = switch (themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _storage.write(key: _themeModeKey, value: value);
  }
}
