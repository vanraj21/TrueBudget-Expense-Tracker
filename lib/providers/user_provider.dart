import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/database_service.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  UserProvider() {
    loadUser();
  }

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();
    
    _user = await DatabaseService.getCurrentUser();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUser(User updatedUser) async {
    _isLoading = true;
    notifyListeners();
    
    await DatabaseService.saveUser(updatedUser);
    _user = await DatabaseService.getCurrentUser();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_user != null) {
      final updatedUser = _user!.copyWith(isDarkMode: !_user!.isDarkMode);
      await updateUser(updatedUser);
    }
  }
}
