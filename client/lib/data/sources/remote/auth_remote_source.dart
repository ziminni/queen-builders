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
        'error': e.response?.data['error'] ?? 'Login failed',
      };
    }
  }
  
  Future<Map<String, dynamic>> register(String email, String fullName, String password, String role) async {
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
      return {
        'success': true,
        'user': UserModel.fromJson(response.data),
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Registration failed',
      };
    }
  }
}