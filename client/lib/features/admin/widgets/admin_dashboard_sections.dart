import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/audit/audit_log_entry.dart';
import '../../../core/audit/audit_log_viewmodel.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/admin_managed_user.dart';
import '../viewmodels/admin_users_viewmodel.dart';
import 'admin_user_editor_dialog.dart';

// ── User management ─────────────────────────────────────────────

class AdminUserManagementContent extends StatefulWidget {
  const AdminUserManagementContent({super.key});

  @override
  State<AdminUserManagementContent> createState() =>
      _AdminUserManagementContentState();
}

class _AdminUserManagementContentState
    extends State<AdminUserManagementContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminUsersViewModel>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminUsersViewModel>(
      builder: (context, usersVm, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Users by role',
                          style: AppTextStyles.h1.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Directory comes from the server (project managers, stock managers, and cashiers in the database). Sign in as an admin with the API running to load and edit accounts.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (usersVm.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(left: 12, top: 4),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    IconButton(
                      tooltip: 'Reload from server',
                      icon: const Icon(Icons.refresh),
                      onPressed: () => usersVm.refresh(),
                    ),
                ],
              ),
              if (usersVm.loadError != null) ...[
                const SizedBox(height: 16),
                Material(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            usersVm.loadError!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => usersVm.refresh(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              _RoleGroupPanel(
                title: 'Project managers',
                subtitle: 'Schedule, budgets, Gantt, project detail',
                icon: Icons.folder_special_outlined,
                role: AdminUserRole.projectManager,
                usersVm: usersVm,
              ),
              const SizedBox(height: 20),
              _RoleGroupPanel(
                title: 'Stock managers',
                subtitle: 'Catalog, receiving, stock alerts, deliveries',
                icon: Icons.inventory_2_outlined,
                role: AdminUserRole.stockManager,
                usersVm: usersVm,
              ),
              const SizedBox(height: 20),
              _RoleGroupPanel(
                title: 'Cashiers',
                subtitle: 'POS sales, pay-later (utang), receipts',
                icon: Icons.point_of_sale_outlined,
                role: AdminUserRole.cashier,
                usersVm: usersVm,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RoleGroupPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final AdminUserRole role;
  final AdminUsersViewModel usersVm;

  const _RoleGroupPanel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.role,
    required this.usersVm,
  });

  @override
  Widget build(BuildContext context) {
    final users = usersVm.usersInRole(role);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Row(
              children: [
                Icon(icon, color: AppColors.richGold, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.h4.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    showAdminUserEditorDialog(
                      context,
                      usersVm: usersVm,
                      defaultRole: role,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.richGold,
                    side: const BorderSide(color: AppColors.richGold, width: 2),
                  ),
                  child: const Text('Add user'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (users.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Text(
                'No users in this group yet.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            for (var i = 0; i < users.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              _UserRow(user: users[i], usersVm: usersVm),
            ],
        ],
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  final ManagedAdminUser user;
  final AdminUsersViewModel usersVm;

  const _UserRow({required this.user, required this.usersVm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.richGold.withValues(alpha: 0.2),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.deepBlack,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      user.role.label,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.richGold,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                Text(
                  user.email,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Login role: ${user.role.authRoleKey}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
                if (user.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    user.notes,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Tooltip(
                message: user.active ? 'Deactivate' : 'Activate',
                child: IconButton(
                  icon: Icon(
                    user.active ? Icons.toggle_on : Icons.toggle_off,
                    color: user.active
                        ? AppColors.success
                        : AppColors.textSecondary,
                    size: 32,
                  ),
                  onPressed: () async {
                    final err = await usersVm.setActive(user.id, !user.active);
                    if (!context.mounted) return;
                    if (err != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(err),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          user.active
                              ? '${user.name} deactivated.'
                              : '${user.name} activated.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: user.active
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.border.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  user.active ? 'Active' : 'Inactive',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: user.active
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  showAdminUserEditorDialog(
                    context,
                    usersVm: usersVm,
                    defaultRole: user.role,
                    existing: user,
                  );
                },
                child: Text(
                  'Edit',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.richGold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// ── Audit logs ────────────────────────────────────────────────────

class AdminAuditLogsContent extends StatefulWidget {
  const AdminAuditLogsContent({super.key});

  @override
  State<AdminAuditLogsContent> createState() => _AdminAuditLogsContentState();
}

class _AdminAuditLogsContentState extends State<AdminAuditLogsContent> {
  String _moduleFilter = _all;
  String _categoryFilter = _all;

  static const _all = 'All';

  List<String> _categoriesForModule(String module) {
    if (module == _all) return [_all];
    switch (module) {
      case AuditLogViewModel.moduleInventory:
        return [
          _all,
          AuditLogViewModel.categoryProductCatalog,
          AuditLogViewModel.categoryReceiving,
        ];
      case AuditLogViewModel.modulePos:
        return [_all, AuditLogViewModel.categorySales];
      case AuditLogViewModel.moduleProjects:
        return [_all, AuditLogViewModel.categoryProject];
      case AuditLogViewModel.moduleAdmin:
        return [_all, AuditLogViewModel.categoryUsers];
      case AuditLogViewModel.moduleSystem:
        return [
          _all,
          AuditLogViewModel.categoryMovement,
          AuditLogViewModel.categorySystem,
        ];
      default:
        return [_all];
    }
  }

  List<AuditLogEntry> _filtered(List<AuditLogEntry> all) {
    return all.where((e) {
      if (_moduleFilter != _all && e.module != _moduleFilter) return false;
      if (_categoryFilter != _all && e.category != _categoryFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuditLogViewModel>(
      builder: (context, audit, _) {
        final filtered = _filtered(audit.entries);
        final categoryOptions = _categoriesForModule(_moduleFilter);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Audit trail',
                style: AppTextStyles.h1.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Events are separated by module, then by category. User management, login/logout movement, inventory, and POS flows write here automatically.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Module',
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(
                    label: _all,
                    selected: _moduleFilter == _all,
                    onSelect: () => setState(() {
                      _moduleFilter = _all;
                      _categoryFilter = _all;
                    }),
                  ),
                  _FilterChip(
                    label: AuditLogViewModel.moduleInventory,
                    selected:
                        _moduleFilter == AuditLogViewModel.moduleInventory,
                    onSelect: () => setState(() {
                      _moduleFilter = AuditLogViewModel.moduleInventory;
                      _categoryFilter = _all;
                    }),
                  ),
                  _FilterChip(
                    label: AuditLogViewModel.modulePos,
                    selected: _moduleFilter == AuditLogViewModel.modulePos,
                    onSelect: () => setState(() {
                      _moduleFilter = AuditLogViewModel.modulePos;
                      _categoryFilter = _all;
                    }),
                  ),
                  _FilterChip(
                    label: AuditLogViewModel.moduleProjects,
                    selected: _moduleFilter == AuditLogViewModel.moduleProjects,
                    onSelect: () => setState(() {
                      _moduleFilter = AuditLogViewModel.moduleProjects;
                      _categoryFilter = _all;
                    }),
                  ),
                  _FilterChip(
                    label: AuditLogViewModel.moduleAdmin,
                    selected: _moduleFilter == AuditLogViewModel.moduleAdmin,
                    onSelect: () => setState(() {
                      _moduleFilter = AuditLogViewModel.moduleAdmin;
                      _categoryFilter = _all;
                    }),
                  ),
                  _FilterChip(
                    label: AuditLogViewModel.moduleSystem,
                    selected: _moduleFilter == AuditLogViewModel.moduleSystem,
                    onSelect: () => setState(() {
                      _moduleFilter = AuditLogViewModel.moduleSystem;
                      _categoryFilter = _all;
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Category',
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in categoryOptions)
                    _FilterChip(
                      label: c,
                      selected: _categoryFilter == c,
                      onSelect: () => setState(() => _categoryFilter = c),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              if (filtered.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: AppColors.textSecondary.withValues(alpha: 0.35),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No entries for this filter',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add a product or receive stock in Inventory, or complete a sale in POS.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < filtered.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        _AuditTile(entry: filtered[i]),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelect;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelect(),
      selectedColor: AppColors.richGold.withValues(alpha: 0.25),
      checkmarkColor: AppColors.deepBlack,
      labelStyle: AppTextStyles.labelSmall.copyWith(
        fontWeight: FontWeight.w600,
        color: selected ? AppColors.deepBlack : AppColors.textPrimary,
      ),
    );
  }
}

class _AuditTile extends StatelessWidget {
  final AuditLogEntry entry;

  const _AuditTile({required this.entry});

  static String _fmt(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Text(
        entry.summary,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          children: [
            _miniBadge(entry.module, AppColors.info),
            const SizedBox(width: 8),
            _miniBadge(entry.category, AppColors.richGold),
            const Spacer(),
            Text(
              _fmt(entry.at),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      children: [
        if (entry.detail != null && entry.detail!.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: SelectableText(
              entry.detail!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          )
        else
          Text(
            'No extra detail',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _miniBadge(String text, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.deepBlack,
        ),
      ),
    );
  }
}

// ── System management ─────────────────────────────────────────────

class AdminSystemManagementContent extends StatelessWidget {
  const AdminSystemManagementContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What lives here',
            style: AppTextStyles.h1.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use this area for non-role, non-audit controls: deployment metadata, integrations, maintenance, and data policies.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          _systemCard(
            title: 'Application',
            body:
                'Build flavor, version string, and API base URL typically appear here for support staff.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kv('Client', 'Queen Builders desktop (Flutter)'),
                _kv('Data mode', 'Demo — in-memory providers'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _systemCard(
            title: 'Operational',
            body:
                'Maintenance windows, read-only mode, and broadcast banners to other modules (future).',
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Maintenance banner (demo)'),
              subtitle: Text(
                'When on, could block writes app-wide — not enforced in this build.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              value: false,
              onChanged: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Toggle stored when backend policy service exists.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _systemCard(
            title: 'Data lifecycle',
            body:
                'Retention for audit exports, backup schedules, and purge rules belong here — not in User management.',
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Export audit — connect object storage or email relay.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.file_download_outlined, size: 18),
              label: const Text('Placeholder: export audit archive'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.richGold,
                side: const BorderSide(color: AppColors.richGold, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _systemCard(
            title: 'Danger zone',
            body: 'Clears the in-memory audit list for this session only.',
            child: Consumer<AuditLogViewModel>(
              builder: (context, audit, _) {
                return OutlinedButton(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(
                          'Clear audit log?',
                          style: AppTextStyles.h3,
                        ),
                        content: Text(
                          'This removes all entries from the current session trail. Continue?',
                          style: AppTextStyles.bodyMedium,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(
                              'Cancel',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(
                              'Clear',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (ok == true && context.mounted) {
                      audit.clearAll();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Audit log cleared.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 2),
                  ),
                  child: const Text('Clear audit log (session)'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _systemCard({
    required String title,
    required String body,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h4.copyWith(fontSize: 17)),
          const SizedBox(height: 8),
          Text(
            body,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              k,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(v, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }
}
