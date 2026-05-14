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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search and Create Button
                        Row(
                          children: [
                            // Search Bar
                            Expanded(
                              child: Consumer<ProjectManagementViewModel>(
                                builder: (context, viewModel, _) => Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 400,
                                  ),
                                  height: 44,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFD9D9D9),
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.search,
                                        color: Color(0xFF8A8A8A),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          onChanged: (value) =>
                                              viewModel.setSearchQuery(value),
                                          decoration: InputDecoration(
                                            hintText: 'Search projects...',
                                            hintStyle: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  color: const Color(
                                                    0xFF8A8A8A,
                                                  ),
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
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Create Project Button
                            _CreateProjectButton(
                              onPressed: () {
                                // Show create project modal
                                _showCreateProjectModal(context);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Projects Grid
                        Expanded(
                          child: Consumer<ProjectManagementViewModel>(
                            builder: (context, viewModel, _) {
                              final filteredProjects =
                                  viewModel.filteredProjects;

                              if (filteredProjects.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.folder_open_outlined,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No projects found',
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 480,
                                      mainAxisSpacing: 24,
                                      crossAxisSpacing: 24,
                                      // Wider tiles, shorter rows (ratio = width / height). Ellipsis on card text avoids overflow.
                                      childAspectRatio: 0.78,
                                    ),
                                itemCount: filteredProjects.length,
                                itemBuilder: (context, index) {
                                  final project = filteredProjects[index];
                                  final totalBudget = viewModel.getTotalBudget(
                                    project.budgetAllocated,
                                  );
                                  final totalExpenses = viewModel
                                      .getTotalExpenses(project.expenses);
                                  final criticalIssues = viewModel
                                      .getCriticalIssuesCount(project);

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
                              );
                            },
                          ),
                        ),
                      ],
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
