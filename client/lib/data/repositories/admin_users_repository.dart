import '../../features/admin/models/admin_managed_user.dart';
import '../sources/remote/admin_users_remote_source.dart';

class AdminUsersRepository {
  AdminUsersRepository({AdminUsersRemoteSource? remote})
      : _remote = remote ?? AdminUsersRemoteSource();

  final AdminUsersRemoteSource _remote;

  ManagedAdminUser _mapRow(Map<String, dynamic> json) {
    final roleKey = json['role'] as String?;
    final role = AdminUserRole.fromAuthRoleKey(roleKey);
    if (role == null) {
      throw FormatException('Unknown role: $roleKey');
    }
    final id = json['id'];
    final idStr = id is int ? '$id' : id.toString();
    return ManagedAdminUser(
      id: idStr,
      name: json['full_name'] as String? ?? '',
      email: (json['email'] as String? ?? '').toLowerCase(),
      role: role,
      active: json['is_active'] as bool? ?? true,
      notes: json['notes'] as String? ?? '',
    );
  }

  Future<List<ManagedAdminUser>> fetchDirectoryUsers() async {
    final raw = await _remote.fetchDirectoryUsers();
    return raw.map((e) => _mapRow(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<ManagedAdminUser> createUser({
    required String email,
    required String fullName,
    required String password,
    required AdminUserRole role,
    required bool isActive,
    String notes = '',
  }) async {
    final json = await _remote.createUser(
      email: email.trim().toLowerCase(),
      fullName: fullName.trim(),
      password: password.trim(),
      role: role.authRoleKey,
      isActive: isActive,
      notes: notes.trim(),
    );
    return _mapRow(json);
  }

  Future<ManagedAdminUser> updateUser(
    ManagedAdminUser user, {
    String? newPassword,
  }) async {
    final json = await _remote.updateUser(
      user.id,
      email: user.email.trim().toLowerCase(),
      fullName: user.name.trim(),
      role: user.role.authRoleKey,
      isActive: user.active,
      notes: user.notes.trim(),
      password: newPassword,
    );
    return _mapRow(json);
  }

  Future<void> deleteUser(String id) => _remote.deleteUser(id);
}
