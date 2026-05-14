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
      await _storage.saveAuthData('local_access', 'local_refresh', localRole);
      return true;
    }

    final result = await _remoteSource.login(email, password);
    
    if (result['success'] == true) {
      await _storage.saveAuthData(
        result['accessToken'],
        result['refreshToken'],
        result['role'],
      );
      return true;
    }
    return false;
  }
  
  Future<String?> getRole() async {
    return await _storage.getToken('user_role');
  }
  
  Future<void> logout() async {
    await _storage.clearAll();
  }
  
  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken('access_token');
    return token != null;
  }
}