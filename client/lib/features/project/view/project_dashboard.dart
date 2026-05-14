import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../../routes/routes.dart';
import '../viewmodel/project_management_viewmodel.dart';
import '../widgets/project_sidebar.dart';
import '../widgets/project_header.dart';
import '../widgets/project_card.dart';
import '../widgets/create_project_dialog.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ProjectManagementDashboard extends StatelessWidget {
  const ProjectManagementDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProjectManagementViewModel(),
      child: const _ProjectManagementDashboardContent(),
    );
  }
}

class _ProjectManagementDashboardContent extends StatelessWidget {
  const _ProjectManagementDashboardContent();

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    await context.read<AuthViewModel>().logout();
    if (context.mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softWhite,
      body: Row(
        children: [
          // Sidebar
          Consumer<ProjectManagementViewModel>(
            builder: (context, viewModel, _) => ProjectSidebar(
              isOpen: viewModel.sidebarOpen,
              activeNav: viewModel.activeNav,
              onNavChanged: (nav) => viewModel.setActiveNav(nav),
            ),
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                Consumer<ProjectManagementViewModel>(
                  builder: (context, viewModel, _) => ProjectHeader(
                    onMenuToggle: () => viewModel.toggleSidebar(),
                    onLogout: () => _handleLogout(context),
                    onSettings: () {
                      // Show admin settings modal
                      _showAdminModal(context);
                    },
                  ),
                ),

                // Content Area
                Expanded(
                  child: Container(
                    color: const Color(0xFFFAFAFA),
                    padding: const EdgeInsets.all(24),
                    child: Consumer<ProjectManagementViewModel>(
                      builder: (context, viewModel, _) {
                        switch (viewModel.activeNav) {
                          case 'team':
                            return const _TeamSection();
                          case 'reports':
                            return _ReportsSection(viewModel: viewModel);
                          case 'settings':
                            return const _SettingsSection();
                          case 'projects':
                          default:
                            return _ProjectsSection(
                              viewModel: viewModel,
                              onCreateProject: () =>
                                  _showCreateProjectModal(context),
                            );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAdminModal(BuildContext context) {
    // TODO: Implement admin modal
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Settings'),
        content: const Text('Admin settings functionality coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCreateProjectModal(BuildContext context) {
    final viewModel = context.read<ProjectManagementViewModel>();
    showDialog<void>(
      context: context,
      builder: (context) =>
          CreateProjectDialog(onCreateProject: viewModel.addProject),
    );
  }
}

class _ProjectsSection extends StatelessWidget {
  final ProjectManagementViewModel viewModel;
  final VoidCallback onCreateProject;

  const _ProjectsSection({
    required this.viewModel,
    required this.onCreateProject,
  });

  @override
  Widget build(BuildContext context) {
    final filteredProjects = viewModel.filteredProjects;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _SearchBox(
                hint: 'Search projects...',
                onChanged: viewModel.setSearchQuery,
              ),
            ),
            const SizedBox(width: 16),
            _CreateProjectButton(onPressed: onCreateProject),
          ],
        ),
        const SizedBox(height: 24),
        if (viewModel.isLoadingProjects)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (filteredProjects.isEmpty)
          const Expanded(
            child: _EmptyState(
              icon: Icons.folder_open_outlined,
              title: 'No projects found',
            ),
          )
        else
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 480,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 0.78,
              ),
              itemCount: filteredProjects.length,
              itemBuilder: (context, index) {
                final project = filteredProjects[index];
                final totalBudget = viewModel.getTotalBudget(
                  project.budgetAllocated,
                );
                final totalExpenses = viewModel.getTotalExpenses(
                  project.expenses,
                );
                final criticalIssues = viewModel.getCriticalIssuesCount(
                  project,
                );

                return ProjectCard(
                  project: project,
                  totalBudget: totalBudget,
                  totalExpenses: totalExpenses,
                  criticalIssues: criticalIssues,
                  onTap: () {
                    context.push(
                      '/project/detail/${project.id}',
                      extra: project,
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

class _TeamSection extends StatelessWidget {
  const _TeamSection();

  static const _members = [
    _TeamMember(
      name: 'Maria Santos',
      role: 'Project Manager',
      phone: '(02) 8842-1111',
      email: 'maria.santos@queenbuilders.ph',
      projects: 'Skyline Tower Phase 2',
      status: 'Available',
    ),
    _TeamMember(
      name: 'Rafael Cruz',
      role: 'Project Manager',
      phone: '(02) 8842-2222',
      email: 'rafael.cruz@queenbuilders.ph',
      projects: 'Residential fit-out pipeline',
      status: 'On Site',
    ),
    _TeamMember(
      name: 'Juan Dela Cruz',
      role: 'Foreman',
      phone: '0917 555 0184',
      email: 'juan.delacruz@queenbuilders.ph',
      projects: 'Skyline Tower Phase 2',
      status: 'On Site',
    ),
    _TeamMember(
      name: 'Elena Ramos',
      role: 'Foreman',
      phone: '0917 555 0197',
      email: 'elena.ramos@queenbuilders.ph',
      projects: 'Upcoming structural works',
      status: 'Available',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'Team',
          subtitle: 'Mock directory of project managers and foremen.',
        ),
        const SizedBox(height: 20),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 980 ? 2 : 1;
              final gap = 16.0;
              final width =
                  (constraints.maxWidth - (columns - 1) * gap) / columns;
              return SingleChildScrollView(
                child: Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final member in _members)
                      SizedBox(width: width, child: _TeamMemberCard(member)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ReportsSection extends StatelessWidget {
  final ProjectManagementViewModel viewModel;

  const _ReportsSection({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final projects = viewModel.projects;
    final totalBudget = projects.fold<double>(
      0,
      (sum, p) => sum + p.budgetAllocated.total,
    );
    final totalExpenses = projects.fold<double>(
      0,
      (sum, p) => sum + viewModel.getTotalExpenses(p.expenses),
    );
    final openIssues = projects.fold<int>(
      0,
      (sum, p) => sum + p.issues.where((i) => i.status != 'Resolved').length,
    );
    final averageProgress = projects.isEmpty
        ? 0
        : (projects.fold<int>(0, (sum, p) => sum + p.progress) /
                  projects.length)
              .round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'Reports',
          subtitle: 'Portfolio summary generated from current project records.',
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _ReportMetricCard(
              icon: Icons.business_center_outlined,
              label: 'Active projects',
              value: '${projects.length}',
            ),
            _ReportMetricCard(
              icon: Icons.trending_up,
              label: 'Average progress',
              value: '$averageProgress%',
            ),
            _ReportMetricCard(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Total budget',
              value: _peso(totalBudget),
            ),
            _ReportMetricCard(
              icon: Icons.receipt_long_outlined,
              label: 'Actual expenses',
              value: _peso(totalExpenses),
            ),
            _ReportMetricCard(
              icon: Icons.report_problem_outlined,
              label: 'Open issues',
              value: '$openIssues',
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _Panel(
            child: projects.isEmpty
                ? const _EmptyState(
                    icon: Icons.description_outlined,
                    title: 'No report data yet',
                  )
                : ListView.separated(
                    itemCount: projects.length,
                    separatorBuilder: (_, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      final spent = viewModel.getTotalExpenses(
                        project.expenses,
                      );
                      final budget = project.budgetAllocated.total;
                      final variance = budget - spent;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    project.name,
                                    style: AppTextStyles.labelLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${project.client} · ${project.status}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(child: Text('${project.progress}%')),
                            Expanded(child: Text(_peso(budget))),
                            Expanded(child: Text(_peso(spent))),
                            Expanded(
                              child: Text(
                                _peso(variance),
                                style: TextStyle(
                                  color: variance < 0
                                      ? AppColors.error
                                      : AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatefulWidget {
  const _SettingsSection();

  @override
  State<_SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<_SettingsSection> {
  bool _emailReports = true;
  bool _criticalAlerts = true;
  bool _autoArchive = false;
  String _defaultView = 'Projects';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'Settings',
          subtitle: 'Project workspace preferences for planning and reporting.',
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Workspace', style: AppTextStyles.h4),
                      const SizedBox(height: 16),
                      _SettingRow(
                        icon: Icons.dashboard_customize_outlined,
                        title: 'Default landing view',
                        subtitle:
                            'Choose which section project managers see first.',
                        trailing: DropdownButton<String>(
                          value: _defaultView,
                          items: const ['Projects', 'Team', 'Reports']
                              .map(
                                (v) =>
                                    DropdownMenuItem(value: v, child: Text(v)),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _defaultView = value);
                            }
                          },
                        ),
                      ),
                      const Divider(height: 28),
                      _SettingSwitch(
                        icon: Icons.mail_outline,
                        title: 'Email weekly project reports',
                        subtitle:
                            'Send a weekly portfolio snapshot to managers.',
                        value: _emailReports,
                        onChanged: (v) => setState(() => _emailReports = v),
                      ),
                      _SettingSwitch(
                        icon: Icons.notification_important_outlined,
                        title: 'Critical issue alerts',
                        subtitle: 'Highlight high-priority unresolved issues.',
                        value: _criticalAlerts,
                        onChanged: (v) => setState(() => _criticalAlerts = v),
                      ),
                      _SettingSwitch(
                        icon: Icons.archive_outlined,
                        title: 'Auto-archive completed projects',
                        subtitle:
                            'Move completed projects out of the active list.',
                        value: _autoArchive,
                        onChanged: (v) => setState(() => _autoArchive = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Data Status', style: AppTextStyles.h4),
                      const SizedBox(height: 12),
                      _InfoLine(
                        icon: Icons.cloud_done_outlined,
                        text: 'Projects load from the Django project backend.',
                      ),
                      const SizedBox(height: 8),
                      _InfoLine(
                        icon: Icons.group_outlined,
                        text:
                            'Team directory is mock-only until user assignment is added.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h1.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SearchBox extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchBox({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9D9D9), width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF8A8A8A), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFF8A8A8A),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: child,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;

  const _EmptyState({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamMember {
  final String name;
  final String role;
  final String phone;
  final String email;
  final String projects;
  final String status;

  const _TeamMember({
    required this.name,
    required this.role,
    required this.phone,
    required this.email,
    required this.projects,
    required this.status,
  });
}

class _TeamMemberCard extends StatelessWidget {
  final _TeamMember member;

  const _TeamMemberCard(this.member);

  @override
  Widget build(BuildContext context) {
    final isManager = member.role == 'Project Manager';
    return _Panel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.richGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isManager ? Icons.manage_accounts_outlined : Icons.engineering,
              color: AppColors.richGold,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(member.name, style: AppTextStyles.h4)),
                    _StatusPill(member.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  member.role,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.richGold,
                  ),
                ),
                const SizedBox(height: 12),
                _InfoLine(icon: Icons.phone_outlined, text: member.phone),
                const SizedBox(height: 6),
                _InfoLine(icon: Icons.email_outlined, text: member.email),
                const SizedBox(height: 6),
                _InfoLine(
                  icon: Icons.business_center_outlined,
                  text: member.projects,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill(this.status);

  @override
  Widget build(BuildContext context) {
    final active = status == 'On Site';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: (active ? AppColors.info : AppColors.success).withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: AppTextStyles.labelSmall.copyWith(
          color: active ? AppColors.info : AppColors.success,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ReportMetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReportMetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.richGold, size: 24),
            const SizedBox(height: 12),
            Text(value, style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.richGold),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.labelLarge),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        const SizedBox(width: 12),
        trailing,
      ],
    );
  }
}

class _SettingSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: _SettingRow(
        icon: icon,
        title: title,
        subtitle: subtitle,
        trailing: Switch(
          value: value,
          activeThumbColor: AppColors.richGold,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
      ],
    );
  }
}

String _peso(double value) {
  if (value.abs() >= 1000000) {
    return 'PHP ${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value.abs() >= 1000) {
    return 'PHP ${(value / 1000).toStringAsFixed(0)}K';
  }
  return 'PHP ${value.toStringAsFixed(0)}';
}

class _CreateProjectButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _CreateProjectButton({required this.onPressed});

  @override
  State<_CreateProjectButton> createState() => _CreateProjectButtonState();
}

class _CreateProjectButtonState extends State<_CreateProjectButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFF8C6B3F) : AppColors.richGold,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.add, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Create Project',
                style: AppTextStyles.button.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
