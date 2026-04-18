// lib/core/network/api_config.dart
import 'dart:io';

class ApiConfig {
  // For macOS desktop - use localhost directly
  static String getBaseUrl() {
    if (Platform.isMacOS) {
      return 'http://localhost:8000/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    }
    // iOS, Windows, Linux
    return 'http://localhost:8000/api';
  }
  
  static const String loginEndpoint = '/auth/login/';
  static const String registerEndpoint = '/auth/register/';
  static const String refreshEndpoint = '/auth/refresh/';
  
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}