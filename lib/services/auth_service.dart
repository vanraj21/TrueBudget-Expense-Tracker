import 'dart:convert';
import 'dart:io';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticated = false;
  String? _pinHash;

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheckBiometrics || isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  Future<bool> authenticateWithBiometrics(String reason) async {
    try {
      final isAuthenticated = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      
      if (isAuthenticated) {
        _isAuthenticated = true;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> setupPin(String pin) async {
    _pinHash = _hashPin(pin);
    await _savePinHash(_pinHash!);
  }

  Future<bool> authenticateWithPin(String pin) async {
    final savedPinHash = await _loadPinHash();
    if (savedPinHash == null) return false;

    final inputPinHash = _hashPin(pin);
    if (inputPinHash == savedPinHash) {
      _isAuthenticated = true;
      return true;
    }
    return false;
  }

  Future<bool> hasPin() async {
    final pinHash = await _loadPinHash();
    return pinHash != null;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String?> _loadPinHash() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/pin_hash.txt');
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _savePinHash(String pinHash) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/pin_hash.txt');
      await file.writeAsString(pinHash);
      _pinHash = pinHash;
    } catch (e) {
      throw Exception('Failed to save PIN');
    }
  }

  Future<void> clearPin() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/pin_hash.txt');
      if (await file.exists()) {
        await file.delete();
      }
      _pinHash = null;
    } catch (e) {
      throw Exception('Failed to clear PIN');
    }
  }

  Future<bool> authenticate(String reason) async {
    // First try biometrics if available
    if (await isBiometricAvailable()) {
      final biometricResult = await authenticateWithBiometrics(reason);
      if (biometricResult) return true;
    }

    // Fallback to PIN if available
    if (await hasPin()) {
      // PIN authentication should be handled by UI
      return false;
    }

    // No authentication method available
    return false;
  }

  Future<bool> isDeviceSecure() async {
    try {
      // Check if device has any security enabled
      return await _auth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }
}
