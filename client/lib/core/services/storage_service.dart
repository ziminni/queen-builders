// lib/core/services/storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();
  
  // Configure for all platforms
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accountName: 'queen_builders',
    ),
    mOptions: MacOsOptions(),  // No serviceName parameter needed
  );
  
  Future<void> saveToken(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
  
  Future<String?> getToken(String key) async {
    return await _storage.read(key: key);
  }
  
  Future<void> deleteToken(String key) async {
    await _storage.delete(key: key);
  }
  
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
  
  // Convenience methods
  Future<void> saveAuthData(String accessToken, String refreshToken, String role) async {
    await saveToken('access_token', accessToken);
    await saveToken('refresh_token', refreshToken);
    await saveToken('user_role', role);
  }
  
  Future<Map<String, String?>> getAuthData() async {
    return {
      'access_token': await getToken('access_token'),
      'refresh_token': await getToken('refresh_token'),
      'user_role': await getToken('user_role'),
    };
  }
}