import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _hasPin = false;
  bool _biometricAvailable = false;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get hasPin => _hasPin;
  bool get biometricAvailable => _biometricAvailable;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    _hasPin = await _authService.hasPin();
    _biometricAvailable = await _authService.isBiometricAvailable();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> authenticateWithBiometrics(String reason) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.authenticateWithBiometrics(reason);
      if (result) {
        _isAuthenticated = true;
      }
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = 'Biometric authentication failed';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> authenticateWithPin(String pin) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.authenticateWithPin(pin);
      if (result) {
        _isAuthenticated = true;
      } else {
        _errorMessage = 'Incorrect PIN';
      }
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = 'Authentication failed';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> setupPin(String pin) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.setupPin(pin);
      _hasPin = true;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to setup PIN';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> canUseBiometrics() async {
    return await _authService.isBiometricAvailable();
  }

  Future<bool> isDeviceSecure() async {
    return await _authService.isDeviceSecure();
  }
}
