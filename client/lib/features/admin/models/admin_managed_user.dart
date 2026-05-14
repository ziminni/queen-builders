import 'package:flutter/foundation.dart';

/// App roles that map to route access (see [AppRoutes.getDashboardRoute]).
enum AdminUserRole {
  projectManager,
  stockManager,
  cashier;

  String get label {
    switch (this) {
      case AdminUserRole.projectManager:
        return 'Project manager';
      case AdminUserRole.stockManager:
        return 'Stock manager';
      case AdminUserRole.cashier:
        return 'Cashier';
    }
  }

  /// Backend / auth role string used elsewhere in the app.
  String get authRoleKey {
    switch (this) {
      case AdminUserRole.projectManager:
        return 'projectManager';
      case AdminUserRole.stockManager:
        return 'stockManager';
      case AdminUserRole.cashier:
        return 'cashier';
    }
  }

  static AdminUserRole? fromAuthRoleKey(String? key) {
    switch (key) {
      case 'projectManager':
        return AdminUserRole.projectManager;
      case 'stockManager':
        return AdminUserRole.stockManager;
      case 'cashier':
        return AdminUserRole.cashier;
      default:
        return null;
    }
  }
}

@immutable
class ManagedAdminUser {
  final String id;
  final String name;
  final String email;
  final AdminUserRole role;
  final bool active;
  final String notes;

  const ManagedAdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.active,
    this.notes = '',
  });

  ManagedAdminUser copyWith({
    String? id,
    String? name,
    String? email,
    AdminUserRole? role,
    bool? active,
    String? notes,
  }) {
    return ManagedAdminUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      active: active ?? this.active,
      notes: notes ?? this.notes,
    );
  }
}
