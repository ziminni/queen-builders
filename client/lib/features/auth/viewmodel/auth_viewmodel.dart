// lib/features/auth/viewmodel/auth_viewmodel.dart
import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../model/auth_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  AuthState _state = AuthState();
  
  AuthViewModel() {
    checkAuthStatus();
  }
  
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
      _updateState(
        isAuthenticated: true,
        userRole: role,
        isLoading: false,
      );
      return true;
    } else {
      _updateState(
        isLoading: false,
        errorMessage: 'Invalid email or password',
      );
      return false;
    }
  }
  
  Future<void> logout() async {
    await _repository.logout();
    _updateState(
      isAuthenticated: false,
      userRole: null,
      errorMessage: null,
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