import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/project.dart';
import '../viewmodel/project_detail_viewmodel.dart';
import '../widgets/metric_cards.dart';
import '../widgets/project_finance_wbs_panel.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../desktop/open_project_gantt_window.dart';

// Mock project data
class ProjectInfo {
  final int id;
  final String name;
  final String client;
  final String location;
  final double totalBudget;
  final String startDate;
  final String deadline;

  ProjectInfo({
    required this.id,
    required this.name,
    required this.client,
    required this.location,
    required this.totalBudget,
    required this.startDate,
    required this.deadline,
  });
}

class ProjectDetailPage extends StatelessWidget {
  final int projectId;

  /// When opened from the project list, carries full domain data for display.
  final Project? project;

  const ProjectDetailPage({super.key, required this.projectId, this.project});

  ProjectInfo _projectInfoFromDomain(Project p) {
    return ProjectInfo(
      id: p.id,
      name: p.name,
      client: p.client,
      location: p.location,
      totalBudget: p.budgetAllocated.total,
      startDate: p.startDate,
      deadline: p.deadline,
    );
  }

  // Mock project data when no [project] extra is passed (e.g. deep link).
  ProjectInfo _getMockProject() {
    final mockProjects = {
      1: ProjectInfo(
        id: 1,
        name: 'Downtown Office Complex',
        client: 'Metro Realty Group',
        location: 'New York, NY',
        totalBudget: 5000000,
        startDate: '2026-03-01',
        deadline: '2026-12-31',
      ),
      2: ProjectInfo(
        id: 2,
        name: 'Residential Tower Renovation',
        client: 'Urban Living LLC',
        location: 'Chicago, IL',
        totalBudget: 2500000,
        startDate: '2026-04-01',
        deadline: '2026-10-31',
      ),
    };

    return mockProjects[projectId] ?? mockProjects[1]!;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedProject = project != null
        ? _projectInfoFromDomain(project!)
        : _getMockProject();
    final vmId = project?.id ?? projectId;

    return ChangeNotifierProvider(
      create: (_) => ProjectDetailViewModel(
        vmId,
        totalAllocatedBudget: resolvedProject.totalBudget,
      ),
      child: _ProjectDetailPageContent(project: resolvedProject),
    );
  }
}

class _ProjectDetailPageContent extends StatelessWidget {
  final ProjectInfo project;

  const _ProjectDetailPageContent({required this.project});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('M/d/yyyy');
    final numberFormat = NumberFormat('#,##0', 'en_US');

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Header
          Consumer<ProjectDetailViewModel>(
            builder: (context, viewModel, _) {
              final metrics = viewModel.calculateMetrics(project.totalBudget);

              return Container(
                color: Colors.white,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button and title
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back),
                            tooltip: 'Back',
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project.name,
                                  style: AppTextStyles.h1.copyWith(
                                    fontFamily: AppTextStyles.cinzelFont,
                                    fontSize: 28,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 16,
                                  children: [
                                    Text(
                                      'Client: ${project.client}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      '•',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      project.location,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      '•',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.calendar_today_outlined,
                                          size: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${dateFormat.format(DateTime.parse(project.startDate))} - ${dateFormat.format(DateTime.parse(project.deadline))}',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Key Metrics
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              label: 'Total Budget',
                              value:
                                  '\$${numberFormat.format(project.totalBudget)}',
                              icon: Icons.attach_money,
                              iconColor: AppColors.richGold,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MetricCard(
                              label: 'Planned Cost',
                              value:
                                  '\$${numberFormat.format(metrics.totalPlanned)}',
                              icon: Icons.trending_up,
                              iconColor: const Color(0xFF3B82F6),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MetricCard(
                              label: 'Actual Cost',
                              value:
                                  '\$${numberFormat.format(metrics.totalActual)}',
                              icon: Icons.trending_up,
                              iconColor: const Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MetricCard(
                              label: 'Remaining',
                              value:
                                  '\$${numberFormat.format(metrics.remaining)}',
                              icon: Icons.attach_money,
                              iconColor: metrics.remaining < 0
                                  ? AppColors.error
                                  : AppColors.success,
                              valueColor: metrics.remaining < 0
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ProgressMetricCard(
                              label: 'Progress',
                              progress: metrics.progress,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Tabs
                      Row(
                        children: [
                          _TabButton(
                            label: 'Overview',
                            isActive: viewModel.activeTab == 'overview',
                            onPressed: () => viewModel.setActiveTab('overview'),
                          ),
                          const SizedBox(width: 8),
                          _TabButton(
                            label: 'Financials',
                            isActive: viewModel.activeTab == 'financials',
                            onPressed: () =>
                                viewModel.setActiveTab('financials'),
                          ),
                          const SizedBox(width: 8),
                          _TabButton(
                            label: 'Gantt Preview',
                            isActive: viewModel.activeTab == 'gantt',
                            onPressed: () => viewModel.setActiveTab('gantt'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Tab Content
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1280),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Consumer<ProjectDetailViewModel>(
                  builder: (context, viewModel, _) {
                    if (viewModel.activeTab == 'overview') {
                      return _OverviewTab(
                        projectId: project.id,
                        projectName: project.name,
                        projectStartDate: project.startDate,
                        projectDeadline: project.deadline,
                        entries: viewModel.entries,
                      );
                    } else if (viewModel.activeTab == 'financials') {
                      return const ProjectFinanceWbsPanel();
                    } else {
                      return _GanttTab(
                        projectId: project.id,
                        projectName: project.name,
                        projectStartDate: project.startDate,
                        projectDeadline: project.deadline,
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Tab Button Widget
class _TabButton extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.richGold
                : (_isHovered ? const Color(0xFFF5F5F5) : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.label,
            style: AppTextStyles.button.copyWith(
              color: widget.isActive ? Colors.white : AppColors.deepBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// Overview Tab
class _OverviewTab extends StatelessWidget {
  final int projectId;
  final String projectName;
  final String projectStartDate;
  final String projectDeadline;
  final List entries;

  const _OverviewTab({
    required this.projectId,
    required this.projectName,
    required this.projectStartDate,
    required this.projectDeadline,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Budget Overview Chart
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Budget Overview',
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              // TODO: Add chart widget (fl_chart or similar)
              Container(
                height: 300,
                alignment: Alignment.center,
                child: Text(
                  'Chart Component - Coming Soon',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Recent Financial Entries
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Financial Entries',
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              entries.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          'No financial entries yet',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Open Gantt Button
        _OpenGanttButton(
          projectId: projectId,
          projectName: projectName,
          projectStartDate: projectStartDate,
          projectDeadline: projectDeadline,
        ),
      ],
    );
  }
}

// Financials tab content is implemented in [ProjectFinanceWbsPanel].
// Gantt Tab
class _GanttTab extends StatelessWidget {
  final int projectId;
  final String projectName;
  final String projectStartDate;
  final String projectDeadline;

  const _GanttTab({
    required this.projectId,
    required this.projectName,
    required this.projectStartDate,
    required this.projectDeadline,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          ),
          child: Center(
            child: Text(
              'Gantt Preview - Coming Soon',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        _OpenGanttButton(
          projectId: projectId,
          projectName: projectName,
          projectStartDate: projectStartDate,
          projectDeadline: projectDeadline,
        ),
      ],
    );
  }
}

// Open Gantt Button
class _OpenGanttButton extends StatefulWidget {
  final int projectId;
  final String projectName;
  final String projectStartDate;
  final String projectDeadline;

  const _OpenGanttButton({
    required this.projectId,
    required this.projectName,
    required this.projectStartDate,
    required this.projectDeadline,
  });

  @override
  State<_OpenGanttButton> createState() => _OpenGanttButtonState();
}

class _OpenGanttButtonState extends State<_OpenGanttButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          final vm = context.read<ProjectDetailViewModel>();
          openProjectGanttWindow(
            context: context,
            projectId: widget.projectId,
            projectName: widget.projectName,
            projectStartDate: widget.projectStartDate,
            projectDeadline: widget.projectDeadline,
            tasks: vm.tasks,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFF8C6B3F) : AppColors.richGold,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Open Full Gantt Chart',
                style: AppTextStyles.button.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.open_in_new, size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
