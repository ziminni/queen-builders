import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/audit/audit_log_viewmodel.dart';
import '../../../data/repositories/admin_users_repository.dart';
import '../../../data/sources/remote/admin_users_remote_source.dart';
import '../models/admin_managed_user.dart';

/// User directory for Admin → User management; backed by Django `/api/admin/directory-users/`.
class AdminUsersViewModel extends ChangeNotifier {
  AdminUsersViewModel({
    AuditLogViewModel? auditLog,
    AdminUsersRepository? repository,
  })  : _auditLog = auditLog,
        _repository = repository ?? AdminUsersRepository();

  final AuditLogViewModel? _auditLog;
  final AdminUsersRepository _repository;
  final List<ManagedAdminUser> _users = [];

  bool _refreshing = false;
  String? _loadError;

  List<ManagedAdminUser> get users => List.unmodifiable(_users);

  bool get isLoading => _refreshing;

  String? get loadError => _loadError;

  List<ManagedAdminUser> usersInRole(AdminUserRole role) {
    return _users.where((u) => u.role == role).toList();
  }

  ManagedAdminUser? getUserById(String id) {
    for (final u in _users) {
      if (u.id == id) return u;
    }
    return null;
  }

  static String? validateNewPassword(String password) {
    final p = password.trim();
    if (p.isEmpty) return 'Password is required.';
    if (p.length < 4) return 'Use at least 4 characters.';
    return null;
  }

  Future<void> refresh() async {
    _refreshing = true;
    _loadError = null;
    notifyListeners();
    try {
      final list = await _repository.fetchDirectoryUsers();
      _users
        ..clear()
        ..addAll(list);
      _loadError = null;
    } catch (e) {
      _loadError =
          e is DioException ? messageFromDioException(e) : e.toString();
    } finally {
      _refreshing = false;
      notifyListeners();
    }
  }

  /// Returns error message, or null on success.
  Future<String?> addUser({
    required String name,
    required String email,
    required String password,
    required AdminUserRole role,
    String notes = '',
    bool active = true,
  }) async {
    final pwErr = validateNewPassword(password);
    if (pwErr != null) return pwErr;

    final trimmedEmail = email.trim().toLowerCase();
    if (trimmedEmail.isEmpty) return 'Email is required.';
    final n = name.trim();
    if (n.isEmpty) return 'Name is required.';

    try {
      final user = await _repository.createUser(
        email: trimmedEmail,
        fullName: n,
        password: password.trim(),
        role: role,
        isActive: active,
        notes: notes.trim(),
      );
      _users.add(user);
      _log(
        'User added: $n · ${role.label}',
        'Email: $trimmedEmail · login password set (not shown)\n'
        '${user.notes.isNotEmpty ? 'Notes: ${user.notes}\n' : ''}'
        'App role key: ${role.authRoleKey}',
      );
      notifyListeners();
      return null;
    } catch (e) {
      return e is DioException ? messageFromDioException(e) : e.toString();
    }
  }

  /// Returns error message, or null on success.
  /// [newPassword] when non-null/non-empty replaces the stored login password.
  Future<String?> updateUser(
    ManagedAdminUser updated, {
    String? newPassword,
  }) async {
    final trimmedEmail = updated.email.trim().toLowerCase();
    if (trimmedEmail.isEmpty) return 'Email is required.';
    final n = updated.name.trim();
    if (n.isEmpty) return 'Name is required.';

    if (newPassword != null && newPassword.trim().isNotEmpty) {
      final pwErr = validateNewPassword(newPassword);
      if (pwErr != null) return pwErr;
    }

    final idx = _users.indexWhere((u) => u.id == updated.id);
    if (idx < 0) return 'User not found.';

    final before = _users[idx];
    final next = updated.copyWith(
      name: n,
      email: trimmedEmail,
      notes: updated.notes.trim(),
    );
    final pw = newPassword != null && newPassword.trim().isNotEmpty
        ? newPassword.trim()
        : null;

    try {
      final saved = await _repository.updateUser(next, newPassword: pw);
      _users[idx] = saved;

      final changes = <String>[];
      if (before.name != saved.name) changes.add('name');
      if (before.email != saved.email) changes.add('email');
      if (before.role != saved.role) {
        changes.add('role → ${saved.role.label}');
      }
      if (before.active != saved.active) {
        changes.add(saved.active ? 'activated' : 'deactivated');
      }
      if (before.notes != saved.notes) changes.add('notes');
      if (pw != null) changes.add('password reset');

      _log(
        'User updated: ${saved.name} (${saved.email})',
        changes.isEmpty ? 'No field changes.' : 'Changed: ${changes.join(', ')}',
      );
      notifyListeners();
      return null;
    } catch (e) {
      return e is DioException ? messageFromDioException(e) : e.toString();
    }
  }

  Future<String?> removeUser(String id) async {
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx < 0) return 'User not found.';
    final removed = _users[idx];
    try {
      await _repository.deleteUser(removed.id);
      _users.removeAt(idx);
      _log(
        'User removed from directory: ${removed.name}',
        'Email: ${removed.email} · was ${removed.role.label}',
      );
      notifyListeners();
      return null;
    } catch (e) {
      return e is DioException ? messageFromDioException(e) : e.toString();
    }
  }

  Future<String?> setActive(String id, bool active) async {
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx < 0) return 'User not found.';
    final u = _users[idx];
    if (u.active == active) return null;
    return updateUser(u.copyWith(active: active));
  }

  void _log(String summary, String detail) {
    _auditLog?.record(
      module: AuditLogViewModel.moduleAdmin,
      category: AuditLogViewModel.categoryUsers,
      summary: summary,
      detail: detail,
    );
  }
}
