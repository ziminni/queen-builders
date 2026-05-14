// lib/data/repositories/auth_repository.dart
import '../sources/remote/auth_remote_source.dart';
import '../../core/auth/local_auth_credentials.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/api_service.dart';

class AuthRepository {
  late final AuthRemoteSource _remoteSource;
  final StorageService _storage = StorageService();

  AuthRepository() {
    final apiService = ApiService();
    _remoteSource = AuthRemoteSource(apiService);
  }

  Future<bool> login(String email, String password) async {
    final localRole = LocalAuthCredentials.instance.tryLogin(email, password);
    if (localRole != null) {
      await _storage.saveAuthData(
        'local_access',
        'local_refresh',
        localRole,
        email: email.trim().toLowerCase(),
        fullName: email.trim(),
      );
      return true;
    }

    final result = await _remoteSource.login(email, password);

    if (result['success'] == true) {
      await _storage.saveAuthData(
        result['accessToken'],
        result['refreshToken'],
        result['role'],
        email: result['user']?.email,
        fullName: result['user']?.fullName,
      );
      return true;
    }
    return false;
  }

  Future<String?> getRole() async {
    return await _storage.getToken('user_role');
  }

  Future<String?> getEmail() async {
    return await _storage.getToken('user_email');
  }

  Future<String?> getFullName() async {
    return await _storage.getToken('user_full_name');
  }

  Future<void> logout() async {
    final auth = await _storage.getAuthData();
    await _remoteSource.logout(
      email: auth['user_email'],
      role: auth['user_role'],
      name: auth['user_full_name'],
    );
    await _storage.clearAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken('access_token');
    return token != null;
  }
}
