import 'package:dio/dio.dart';

import '../../../core/network/api_config.dart';
import '../../../core/services/api_service.dart';

/// Admin directory CRUD (projectManager / stockManager / cashier). Requires admin JWT.
class AdminUsersRemoteSource {
  AdminUsersRemoteSource([ApiService? api]) : _api = api ?? ApiService();

  final ApiService _api;

  Future<List<dynamic>> fetchDirectoryUsers() async {
    final response = await _api.dio.get(ApiConfig.adminDirectoryUsers);
    final data = response.data;
    if (data is! List) {
      throw FormatException('Expected list of users, got ${data.runtimeType}');
    }
    return data;
  }

  Future<Map<String, dynamic>> createUser({
    required String email,
    required String fullName,
    required String password,
    required String role,
    required bool isActive,
    String notes = '',
  }) async {
    final response = await _api.dio.post(
      ApiConfig.adminDirectoryUsers,
      data: {
        'email': email,
        'full_name': fullName,
        'password': password,
        'role': role,
        'is_active': isActive,
        'notes': notes,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updateUser(
    String id, {
    required String email,
    required String fullName,
    required String role,
    required bool isActive,
    required String notes,
    String? password,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'full_name': fullName,
      'role': role,
      'is_active': isActive,
      'notes': notes,
    };
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }
    final response = await _api.dio.patch(
      ApiConfig.adminDirectoryUserDetail(id),
      data: body,
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> deleteUser(String id) async {
    await _api.dio.delete(ApiConfig.adminDirectoryUserDetail(id));
  }
}

String? messageFromDioException(Object e) {
  if (e is DioException) {
    final raw = e.response?.data;
    if (raw is Map) {
      final data = Map<String, dynamic>.from(raw);
      if (data['detail'] != null) {
        return data['detail'].toString();
      }
      final lines = <String>[];
      data.forEach((key, value) {
        if (value is List) {
          lines.add('$key: ${value.join(', ')}');
        } else {
          lines.add('$key: $value');
        }
      });
      if (lines.isNotEmpty) {
        return lines.join('\n');
      }
    }
    return e.message;
  }
  return e.toString();
}
