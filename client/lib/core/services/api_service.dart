// lib/core/services/api_service.dart
import 'package:dio/dio.dart';
import '../network/api_config.dart';
import 'storage_service.dart';

class ApiService {
  late final Dio _dio;
  final StorageService _storage = StorageService();

  /// Local demo login stores placeholders like `local_access`, not a JWT.
  /// Sending those as `Bearer` makes django-rest-framework-simplejwt reject the
  /// request with 401 before `AllowAny` is evaluated.
  static bool _looksLikeJwt(String token) {
    final parts = token.split('.');
    return parts.length >= 3;
  }
  
  ApiService() {
    _initDio();
  }
  
  void _initDio() {
    final baseUrl = ApiConfig.getBaseUrl();
    print('🔧 Initializing API with base URL: $baseUrl'); // Add this debug line
    
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    
    _addInterceptors();
  }
  
  void _addInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getToken('access_token');
        if (token != null && _looksLikeJwt(token)) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print('🌐 ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ ${response.statusCode} ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (error, handler) async {
        print('❌ Error: ${error.message}');
        
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            final retryResponse = await _retry(error.requestOptions);
            return handler.resolve(retryResponse);
          }
        }
        return handler.next(error);
      },
    ));
  }
  
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.getToken('refresh_token');
      if (refreshToken == null || !_looksLikeJwt(refreshToken)) return false;

      final response = await _dio.post(ApiConfig.refreshEndpoint,
        data: {'refresh': refreshToken}
      );

      await _storage.saveToken('access_token', response.data['access']);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<Response> _retry(RequestOptions requestOptions) async {
    final token = await _storage.getToken('access_token');
    if (token != null && _looksLikeJwt(token)) {
      requestOptions.headers['Authorization'] = 'Bearer $token';
    } else {
      requestOptions.headers.remove('Authorization');
    }
    return _dio.fetch(requestOptions);
  }
  
  Dio get dio => _dio;
}