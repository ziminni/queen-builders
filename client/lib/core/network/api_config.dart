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
  static const String adminDirectoryUsers = '/admin/directory-users/';
  static String adminDirectoryUserDetail(String id) =>
      '/admin/directory-users/$id/';
  static const String inventoryProducts = '/inventory/products/';
  static String inventoryProductDetail(int id) => '/inventory/products/$id/';
  static const String inventorySuppliers = '/inventory/suppliers/';
  static const String inventoryDeliveries = '/inventory/deliveries/';
  static const String inventoryReceive = '/inventory/deliveries/receive/';
  static const String inventoryPosCheckout = '/inventory/pos/checkout/';
  static const String inventoryPosSales = '/inventory/pos/sales/';
  static const String projectProjects = '/projectm/projects/';
  static String projectDetail(int id) => '/projectm/projects/$id/';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
