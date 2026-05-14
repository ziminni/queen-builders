// lib/data/sources/remote/auth_remote_source.dart
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../core/network/api_config.dart';
import '../../models/user_model.dart';

class AuthRemoteSource {
  final ApiService _apiService;

  AuthRemoteSource(this._apiService);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.dio.post(
        ApiConfig.loginEndpoint,
        data: {'email': email, 'password': password},
      );
      return {
        'success': true,
        'accessToken': response.data['access'],
        'refreshToken': response.data['refresh'],
        'user': UserModel.fromJson(response.data['user']),
        'role': response.data['role'],
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': _errorMessage(e.response?.data, fallback: 'Login failed'),
      };
    }
  }

  Future<void> logout({String? email, String? role, String? name}) async {
    try {
      await _apiService.dio.post(
        ApiConfig.logoutEndpoint,
        data: {'email': email, 'role': role, 'name': name},
      );
    } on DioException {
      // Logout should not be blocked by movement-log recording failure.
    }
  }

  Future<Map<String, dynamic>> register(
    String email,
    String fullName,
    String password,
    String role,
  ) async {
    try {
      final response = await _apiService.dio.post(
        ApiConfig.registerEndpoint,
        data: {
          'email': email,
          'full_name': fullName,
          'password': password,
          'role': role,
        },
      );
      return {'success': true, 'user': UserModel.fromJson(response.data)};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': _errorMessage(
          e.response?.data,
          fallback: 'Registration failed',
        ),
      };
    }
  }

  String _errorMessage(dynamic data, {required String fallback}) {
    if (data is Map) {
      final error = data['error'] ?? data['detail'];
      if (error != null) return error.toString();
    }
    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }
    return fallback;
  }
}
