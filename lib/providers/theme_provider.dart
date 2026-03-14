import 'package:flutter/material.dart';
import '../services/database_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final user = await DatabaseService.getCurrentUser();
    if (user != null) {
      _isDarkMode = user.isDarkMode;
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _saveTheme();
  }

  Future<void> setTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    await _saveTheme();
  }

  Future<void> _saveTheme() async {
    final user = await DatabaseService.getCurrentUser();
    if (user != null) {
      final updatedUser = user.copyWith(isDarkMode: _isDarkMode);
      await DatabaseService.saveUser(updatedUser);
    }
  }
}
