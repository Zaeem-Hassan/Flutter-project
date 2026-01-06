import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class SettingsService extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  
  AppThemeMode _themeMode = AppThemeMode.system;
  
  AppThemeMode get themeMode => _themeMode;
  
  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  SettingsService() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_themeModeKey) ?? 0;
    _themeMode = AppThemeMode.values[modeIndex];
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  String get themeModeLabel {
    switch (_themeMode) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }
}
