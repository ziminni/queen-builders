// lib/core/services/storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Configure for all platforms
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accountName: 'queen_builders'),
    mOptions: MacOsOptions(), // No serviceName parameter needed
  );

  SharedPreferences? _prefs;

  Future<dynamic> _getStorage() async {
    if (Platform.isMacOS) {
      _prefs ??= await SharedPreferences.getInstance();
      return _prefs;
    } else {
      return _secureStorage;
    }
  }

  Future<void> saveToken(String key, String value) async {
    final storage = await _getStorage();
    if (storage is SharedPreferences) {
      await storage.setString(key, value);
    } else {
      await (storage as FlutterSecureStorage).write(key: key, value: value);
    }
  }

  Future<String?> getToken(String key) async {
    final storage = await _getStorage();
    if (storage is SharedPreferences) {
      return storage.getString(key);
    } else {
      return await (storage as FlutterSecureStorage).read(key: key);
    }
  }

  Future<void> deleteToken(String key) async {
    final storage = await _getStorage();
    if (storage is SharedPreferences) {
      await storage.remove(key);
    } else {
      await (storage as FlutterSecureStorage).delete(key: key);
    }
  }

  Future<void> clearAll() async {
    final storage = await _getStorage();
    if (storage is SharedPreferences) {
      await storage.clear();
    } else {
      await (storage as FlutterSecureStorage).deleteAll();
    }
  }

  // Convenience methods
  Future<void> saveAuthData(
    String accessToken,
    String refreshToken,
    String role, {
    String? email,
    String? fullName,
  }) async {
    await saveToken('access_token', accessToken);
    await saveToken('refresh_token', refreshToken);
    await saveToken('user_role', role);
    if (email != null) await saveToken('user_email', email);
    if (fullName != null) await saveToken('user_full_name', fullName);
  }

  Future<Map<String, String?>> getAuthData() async {
    return {
      'access_token': await getToken('access_token'),
      'refresh_token': await getToken('refresh_token'),
      'user_role': await getToken('user_role'),
      'user_email': await getToken('user_email'),
      'user_full_name': await getToken('user_full_name'),
    };
  }
}
