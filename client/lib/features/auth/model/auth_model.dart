// lib/features/auth/model/auth_model.dart
const Object _unset = Object();

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
    Object? userRole = _unset,
    bool? isLoading,
    Object? errorMessage = _unset,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userRole: identical(userRole, _unset)
          ? this.userRole
          : userRole as String?,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
