// lib/features/auth/viewmodel/auth_viewmodel.dart
import 'package:flutter/material.dart';
import '../../../core/audit/audit_log_viewmodel.dart';
import '../../../data/repositories/auth_repository.dart';
import '../model/auth_model.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({AuditLogViewModel? auditLog, AuthRepository? repository})
    : _auditLog = auditLog,
      _repository = repository ?? AuthRepository() {
    checkAuthStatus();
  }

  final AuthRepository _repository;
  final AuditLogViewModel? _auditLog;
  AuthState _state = AuthState();

  AuthState get state => _state;
  bool get isLoading => _state.isLoading;
  bool get isAuthenticated => _state.isAuthenticated;
  String? get userRole => _state.userRole;
  String? get errorMessage => _state.errorMessage;

  Future<bool> login(String email, String password) async {
    _updateState(isLoading: true, errorMessage: null);

    final success = await _repository.login(email, password);

    if (success) {
      final role = await _repository.getRole();
      final storedEmail = await _repository.getEmail();
      final storedName = await _repository.getFullName();
      _updateState(isAuthenticated: true, userRole: role, isLoading: false);
      _recordMovement(
        summary: 'User logged in: ${storedName ?? storedEmail ?? email.trim()}',
        detail:
            'Email: ${storedEmail ?? email.trim().toLowerCase()}\nRole: ${role ?? 'unknown'}',
      );
      return true;
    } else {
      _updateState(isLoading: false, errorMessage: 'Invalid email or password');
      return false;
    }
  }

  Future<void> logout() async {
    final role = await _repository.getRole();
    final email = await _repository.getEmail();
    final name = await _repository.getFullName();
    await _repository.logout();
    _updateState(isAuthenticated: false, userRole: null, errorMessage: null);
    _recordMovement(
      summary: 'User logged out: ${name ?? email ?? 'Unknown user'}',
      detail: 'Email: ${email ?? 'unknown'}\nRole: ${role ?? 'unknown'}',
    );
  }

  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _repository.isLoggedIn();
    if (isLoggedIn) {
      final role = await _repository.getRole();
      _updateState(isAuthenticated: true, userRole: role);
    } else {
      _updateState(isAuthenticated: false, userRole: null);
    }
  }

  void clearError() {
    _updateState(errorMessage: null);
  }

  void _recordMovement({required String summary, required String detail}) {
    _auditLog?.record(
      module: AuditLogViewModel.moduleSystem,
      category: AuditLogViewModel.categoryMovement,
      summary: summary,
      detail: detail,
    );
  }

  void _updateState({
    bool? isAuthenticated,
    String? userRole,
    bool? isLoading,
    String? errorMessage,
  }) {
    _state = _state.copyWith(
      isAuthenticated: isAuthenticated,
      userRole: userRole,
      isLoading: isLoading,
      errorMessage: errorMessage,
    );
    notifyListeners(); // This triggers GoRouter redirect
  }
}
