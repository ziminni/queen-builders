// lib/features/auth/model/auth_model.dart
class AuthState {
  final bool isAuthenticated;
  final String? userRole;
  final bool isLoading;
  final String? errorMessage;
  
  AuthState({
    this.isAuthenticated = false,
    this.userRole,
    this.isLoading = false,
    this.errorMessage,
  });
  
  AuthState copyWith({
    bool? isAuthenticated,
    String? userRole,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userRole: userRole ?? this.userRole,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}