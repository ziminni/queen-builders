import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/admin_managed_user.dart';
import '../viewmodels/admin_users_viewmodel.dart';

/// Add a user (fixed role from panel) or edit an existing directory user.
Future<void> showAdminUserEditorDialog(
  BuildContext context, {
  required AdminUsersViewModel usersVm,
  required AdminUserRole defaultRole,
  ManagedAdminUser? existing,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => _AdminUserEditorDialog(
      usersVm: usersVm,
      initialRole: existing?.role ?? defaultRole,
      existing: existing,
    ),
  );
}

class _AdminUserEditorDialog extends StatefulWidget {
  final AdminUsersViewModel usersVm;
  final AdminUserRole initialRole;
  final ManagedAdminUser? existing;

  const _AdminUserEditorDialog({
    required this.usersVm,
    required this.initialRole,
    this.existing,
  });

  @override
  State<_AdminUserEditorDialog> createState() => _AdminUserEditorDialogState();
}

class _AdminUserEditorDialogState extends State<_AdminUserEditorDialog> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _passwordConfirm;
  late final TextEditingController _notes;
  late AdminUserRole _role;
  late bool _active;
  bool _obscurePassword = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _email = TextEditingController(text: e?.email ?? '');
    _password = TextEditingController();
    _passwordConfirm = TextEditingController();
    _notes = TextEditingController(text: e?.notes ?? '');
    _role = e?.role ?? widget.initialRole;
    _active = e?.active ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    _notes.dispose();
    super.dispose();
  }

  bool get _isEdit => widget.existing != null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.richGold, width: 2),
      ),
      title: Text(
        _isEdit ? 'Edit user' : 'Add user (${widget.initialRole.label})',
        style: AppTextStyles.h3.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _name,
                decoration: _dec('Full name', 'Required'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _email,
                decoration: _dec('Email', 'Required · used as login id'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: _obscurePassword,
                decoration: _dec('Password', _isEdit ? 'Optional · leave blank to keep current' : 'Required · min 4 characters')
                    .copyWith(
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword ? 'Show' : 'Hide',
                    icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                autocorrect: false,
                enableSuggestions: false,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordConfirm,
                obscureText: _obscurePassword,
                decoration: _dec('Confirm password', 'Must match'),
                autocorrect: false,
                enableSuggestions: false,
              ),
              const SizedBox(height: 12),
              if (_isEdit) ...[
                DropdownButtonFormField<AdminUserRole>(
                  initialValue: _role,
                  decoration: _decRaw('Role'),
                  items: AdminUserRole.values
                      .map(
                        (r) => DropdownMenuItem(
                          value: r,
                          child: Text(r.label),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _role = v);
                  },
                ),
                const SizedBox(height: 8),
              ],
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Active', style: AppTextStyles.bodyMedium),
                subtitle: Text(
                  'Inactive users stay in the directory but can be excluded from assignments.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                value: _active,
                activeThumbColor: AppColors.deepBlack,
                activeTrackColor: AppColors.richGold.withValues(alpha: 0.45),
                onChanged: (v) => setState(() => _active = v),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notes,
                decoration: _dec('Notes', 'Optional'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (_isEdit)
          TextButton(
            onPressed: _saving
                ? null
                : () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (x) => AlertDialog(
                  title: Text('Remove user?', style: AppTextStyles.h3),
                  content: Text(
                    'Remove ${widget.existing!.name} from the directory?',
                    style: AppTextStyles.bodyMedium,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(x, false),
                      child: Text('Cancel', style: AppTextStyles.button.copyWith(color: AppColors.textSecondary)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(x, true),
                      child: Text('Remove', style: AppTextStyles.button.copyWith(color: AppColors.error)),
                    ),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                setState(() => _saving = true);
                final removeErr = await widget.usersVm.removeUser(widget.existing!.id);
                if (!context.mounted) return;
                setState(() => _saving = false);
                if (removeErr != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(removeErr), behavior: SnackBarBehavior.floating),
                  );
                  return;
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.existing!.name} removed.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text('Remove', style: AppTextStyles.button.copyWith(color: AppColors.error)),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: AppTextStyles.button.copyWith(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _saving
              ? null
              : () async {
            final p = _password.text;
            final pConfirm = _passwordConfirm.text;

            if (!_isEdit) {
              final pwErr = AdminUsersViewModel.validateNewPassword(p);
              if (pwErr != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(pwErr), behavior: SnackBarBehavior.floating),
                );
                return;
              }
              if (p.trim() != pConfirm.trim()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match.'), behavior: SnackBarBehavior.floating),
                );
                return;
              }
            } else {
              final a = p.trim();
              final b = pConfirm.trim();
              if (a.isNotEmpty || b.isNotEmpty) {
                if (a != b) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('New passwords do not match.'), behavior: SnackBarBehavior.floating),
                  );
                  return;
                }
                final pwErr = AdminUsersViewModel.validateNewPassword(a);
                if (pwErr != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(pwErr), behavior: SnackBarBehavior.floating),
                  );
                  return;
                }
              }
            }

            setState(() => _saving = true);
            String? err;
            if (_isEdit) {
              final updated = widget.existing!.copyWith(
                name: _name.text,
                email: _email.text,
                role: _role,
                active: _active,
                notes: _notes.text,
              );
              final newPw = p.trim().isEmpty ? null : p.trim();
              err = await widget.usersVm.updateUser(updated, newPassword: newPw);
            } else {
              err = await widget.usersVm.addUser(
                name: _name.text,
                email: _email.text,
                password: p,
                role: widget.initialRole,
                notes: _notes.text,
                active: _active,
              );
            }
            if (!context.mounted) return;
            setState(() => _saving = false);
            if (err != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(err), behavior: SnackBarBehavior.floating),
              );
              return;
            }
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isEdit ? 'User updated.' : 'User added.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.richGold,
            foregroundColor: AppColors.deepBlack,
          ),
          child: _saving
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.deepBlack,
                  ),
                )
              : Text('Save', style: AppTextStyles.button),
        ),
      ],
    );
  }

  InputDecoration _dec(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.richGold, width: 2),
      ),
    );
  }

  InputDecoration _decRaw(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.richGold, width: 2),
      ),
    );
  }
}
