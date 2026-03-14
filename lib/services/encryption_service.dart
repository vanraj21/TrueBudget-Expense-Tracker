import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  static EncryptionService? _initializedInstance;
  factory EncryptionService() => _initializedInstance ?? _instance;
  EncryptionService._internal();

  String? _encryptionKey;

  Future<void> initialize() async {
    if (_encryptionKey == null) {
      try {
        print('Initializing encryption service...');
        _encryptionKey = await _getOrCreateKey();
        _initializedInstance = this;
        print('Encryption service initialized successfully');
      } catch (e) {
        print('Error initializing encryption service: $e');
        // Use fallback key for development
        _encryptionKey = sha256.convert(utf8.encode('true_budget_fallback_key_2024')).toString();
        _initializedInstance = this;
        print('Using fallback encryption key');
      }
    }
  }

  Future<String> _getOrCreateKey() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/encryption_key.txt');
      
      if (await file.exists()) {
        return await file.readAsString();
      } else {
        // Generate a new encryption key
        final key = sha256.convert(utf8.encode('${DateTime.now().millisecondsSinceEpoch}_true_budget_secret')).toString();
        await file.writeAsString(key);
        return key;
      }
    } catch (e) {
      // Fallback to a hardcoded key for development
      return sha256.convert(utf8.encode('true_budget_fallback_key_2024')).toString();
    }
  }

  String encrypt(String plainText) {
    if (_encryptionKey == null) {
      throw Exception('Encryption service not initialized');
    }
    
    try {
      // Simple XOR encryption with SHA256 key
      final keyBytes = utf8.encode(_encryptionKey!);
      final textBytes = utf8.encode(plainText);
      final encryptedBytes = <int>[];
      
      for (int i = 0; i < textBytes.length; i++) {
        encryptedBytes.add(textBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return base64.encode(encryptedBytes);
    } catch (e) {
      throw Exception('Failed to encrypt data: $e');
    }
  }

  String decrypt(String encryptedText) {
    if (_encryptionKey == null) {
      throw Exception('Encryption service not initialized');
    }
    
    try {
      final keyBytes = utf8.encode(_encryptionKey!);
      final encryptedBytes = base64.decode(encryptedText);
      final decryptedBytes = <int>[];
      
      for (int i = 0; i < encryptedBytes.length; i++) {
        decryptedBytes.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return utf8.decode(decryptedBytes);
    } catch (e) {
      throw Exception('Failed to decrypt data: $e');
    }
  }

  Map<String, dynamic> encryptMap(Map<String, dynamic> data) {
    final encryptedData = <String, dynamic>{};
    
    for (final entry in data.entries) {
      if (entry.value is String) {
        encryptedData[entry.key] = encrypt(entry.value as String);
      } else if (entry.value is num) {
        encryptedData[entry.key] = encrypt(entry.value.toString());
      } else if (entry.value is bool) {
        encryptedData[entry.key] = encrypt(entry.value.toString());
      } else {
        encryptedData[entry.key] = entry.value; // Keep non-sensitive data as is
      }
    }
    
    return encryptedData;
  }

  Map<String, dynamic> decryptMap(Map<String, dynamic> encryptedData) {
    final decryptedData = <String, dynamic>{};
    
    for (final entry in encryptedData.entries) {
      if (entry.value is String) {
        try {
          // Try to decrypt, if it fails, keep original value
          decryptedData[entry.key] = decrypt(entry.value as String);
        } catch (e) {
          decryptedData[entry.key] = entry.value; // Keep as is if not encrypted
        }
      } else {
        decryptedData[entry.key] = entry.value;
      }
    }
    
    return decryptedData;
  }

  String encryptSensitiveField(String value) {
    if (value.isEmpty) return value;
    return encrypt(value);
  }

  String decryptSensitiveField(String encryptedValue) {
    if (encryptedValue.isEmpty) return encryptedValue;
    try {
      return decrypt(encryptedValue);
    } catch (e) {
      return encryptedValue; // Return original if decryption fails
    }
  }

  Future<void> clearEncryptionKey() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/encryption_key.txt');
      if (await file.exists()) {
        await file.delete();
      }
      _encryptionKey = null;
    } catch (e) {
      throw Exception('Failed to clear encryption key: $e');
    }
  }

  bool get isInitialized => _encryptionKey != null;

  // For financial data encryption
  String encryptFinancialAmount(double amount) {
    return encrypt(amount.toString());
  }

  double decryptFinancialAmount(String encryptedAmount) {
    try {
      final decrypted = decrypt(encryptedAmount);
      return double.parse(decrypted);
    } catch (e) {
      return 0.0; // Return default value if decryption fails
    }
  }

  // For transaction notes encryption
  String encryptTransactionNote(String? note) {
    if (note == null || note.isEmpty) return '';
    return encrypt(note);
  }

  String decryptTransactionNote(String encryptedNote) {
    if (encryptedNote.isEmpty) return '';
    try {
      return decrypt(encryptedNote);
    } catch (e) {
      return encryptedNote; // Return original if decryption fails
    }
  }
}
