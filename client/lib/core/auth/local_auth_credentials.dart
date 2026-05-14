import 'package:flutter/foundation.dart';

/// Demo-local login credentials managed from Admin → User management.
/// Passwords are kept **in memory only** (not secure for production).
///
/// Login flow: [tryLogin] is consulted before the remote API.
@immutable
class _StoredCred {
  final String password;
  final String roleKey;

  const _StoredCred({required this.password, required this.roleKey});
}

class LocalAuthCredentials {
  LocalAuthCredentials._();
  static final LocalAuthCredentials instance = LocalAuthCredentials._();

  /// Default password for seeded directory users so they can sign in immediately.
  static const String defaultSeedPassword = 'demo123';

  final Map<String, _StoredCred> _byUserId = {};
  final Map<String, String> _userIdByEmailLower = {};

  /// Returns role key for [AppRoutes.getDashboardRoute], or null if unknown or wrong password.
  String? tryLogin(String email, String password) {
    final id = _userIdByEmailLower[email.trim().toLowerCase()];
    if (id == null) return null;
    final c = _byUserId[id];
    if (c == null) return null;
    if (c.password != password) return null;
    return c.roleKey;
  }

  void seedUser({
    required String userId,
    required String email,
    required String roleKey,
    required String password,
    required bool loginEnabled,
  }) {
    _byUserId[userId] = _StoredCred(password: password, roleKey: roleKey);
    final el = email.trim().toLowerCase();
    if (loginEnabled) {
      _userIdByEmailLower[el] = userId;
    }
  }

  void registerNewUser({
    required String userId,
    required String email,
    required String roleKey,
    required String password,
    bool active = true,
  }) {
    _byUserId[userId] = _StoredCred(password: password, roleKey: roleKey);
    final el = email.trim().toLowerCase();
    _userIdByEmailLower.removeWhere((_, v) => v == userId);
    if (active) {
      _userIdByEmailLower[el] = userId;
    }
  }

  void removeUser(String userId, String email) {
    _byUserId.remove(userId);
    _userIdByEmailLower.remove(email.trim().toLowerCase());
    _userIdByEmailLower.removeWhere((_, v) => v == userId);
  }

  /// Email changed: remap lookup; keeps password unless [newPassword] provided.
  void updateUser({
    required String userId,
    required String oldEmail,
    required String newEmail,
    required String roleKey,
    required bool active,
    String? newPassword,
  }) {
    final oldCred = _byUserId[userId] ??
        _StoredCred(password: '', roleKey: roleKey);

    final pass = (newPassword != null && newPassword.isNotEmpty)
        ? newPassword
        : oldCred.password;

    _byUserId[userId] = _StoredCred(password: pass, roleKey: roleKey);

    _userIdByEmailLower.remove(oldEmail.trim().toLowerCase());
    if (active) {
      _userIdByEmailLower[newEmail.trim().toLowerCase()] = userId;
    }
  }

  /// Inactive users cannot log in; password retained for reactivation.
  void setLoginEnabled(String userId, String email, bool enabled) {
    final el = email.trim().toLowerCase();
    if (enabled) {
      if (_byUserId.containsKey(userId)) {
        _userIdByEmailLower[el] = userId;
      }
    } else {
      _userIdByEmailLower.remove(el);
    }
  }
}
