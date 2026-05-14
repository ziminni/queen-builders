import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/material.dart' as project_material;
import '../models/budget_allocation.dart';
import '../models/expense.dart';
import '../models/progress_log.dart';
import '../models/issue.dart';
import '../models/comment.dart';
import '../../../data/repositories/project_repository.dart';

class ProjectManagementViewModel extends ChangeNotifier {
  ProjectManagementViewModel({ProjectRepository? repository})
    : _repository = repository ?? ProjectRepository() {
    loadProjectsFromApi();
  }

  final ProjectRepository _repository;
  List<Project> _projects = [];
  String _searchQuery = '';
  String _activeNav = 'projects';
  bool _sidebarOpen = true;
  bool isLoadingProjects = false;
  bool isSavingProject = false;
  bool usingOfflineSample = false;
  String? projectError;

  List<Project> get projects => _projects;
  String get searchQuery => _searchQuery;
  String get activeNav => _activeNav;
  bool get sidebarOpen => _sidebarOpen;

  List<Project> get filteredProjects {
    if (_searchQuery.isEmpty) return _projects;

    return _projects.where((project) {
      final query = _searchQuery.toLowerCase();
      return project.name.toLowerCase().contains(query) ||
          project.client.toLowerCase().contains(query) ||
          project.foreman.toLowerCase().contains(query) ||
          project.location.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> loadProjectsFromApi({bool useSampleFallback = true}) async {
    isLoadingProjects = true;
    projectError = null;
    notifyListeners();
    try {
      _projects = await _repository.fetchProjects();
      usingOfflineSample = false;
    } catch (e) {
      projectError = e.toString();
      if (useSampleFallback && _projects.isEmpty) {
        _loadSampleData(notify: false);
        usingOfflineSample = true;
      }
    } finally {
      isLoadingProjects = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setActiveNav(String nav) {
    if (nav == 'materials') return;
    _activeNav = nav;
    notifyListeners();
  }

  void toggleSidebar() {
    _sidebarOpen = !_sidebarOpen;
    notifyListeners();
  }

  Future<void> addProject(Project project) async {
    if (usingOfflineSample) {
      _projects = [..._projects, project];
      notifyListeners();
      return;
    }
    isSavingProject = true;
    projectError = null;
    notifyListeners();
    try {
      final saved = await _repository.createProject(project);
      _projects = [saved, ..._projects];
    } catch (e) {
      projectError = e.toString();
      rethrow;
    } finally {
      isSavingProject = false;
      notifyListeners();
    }
  }

  Future<void> removeProject(int projectId) async {
    if (!usingOfflineSample) {
      await _repository.deleteProject(projectId);
    }
    _projects = _projects.where((p) => p.id != projectId).toList();
    notifyListeners();
  }

  double getTotalBudget(BudgetAllocation budgetAllocated) {
    return budgetAllocated.total;
  }

  double getTotalExpenses(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  int getCriticalIssuesCount(Project project) {
    return project.issues
        .where(
          (issue) => issue.priority == 'High' && issue.status != 'Resolved',
        )
        .length;
  }

  void _loadSampleData({bool notify = true}) {
    // Sample project data matching the React version
    _projects = [
      Project(
        id: 1,
        name: 'Skyline Tower Phase 2',
        client: 'Urban Developments Inc.',
        foreman: 'Juan Dela Cruz',
        status: 'In Progress',
        location: '1250 Metro Avenue, Business District, Metro Manila',
        progress: 68,
        budgetAllocated: BudgetAllocation(
          materials: 500000,
          labor: 250000,
          equipment: 100000,
        ),
        startDate: '2026-01-15',
        deadline: '2026-04-30',
        materials: [
          project_material.Material(
            id: 1,
            name: 'Steel Beams',
            category: 'Steel',
            quantityRequired: 200,
            quantityReceived: 150,
            used: 150,
            available: 0,
            unitCost: 2500,
            unit: 'pieces',
            status: 'OUT',
          ),
          project_material.Material(
            id: 2,
            name: 'Cement Bags',
            category: 'Cement',
            quantityRequired: 600,
            quantityReceived: 500,
            used: 425,
            available: 75,
            unitCost: 300,
            unit: 'bags',
            status: 'LOW',
          ),
        ],
        expenses: [
          Expense(
            id: 1,
            date: '2026-04-20',
            category: 'Materials',
            description: 'Steel beam delivery batch 3',
            amount: 375000,
            addedBy: 'Admin',
          ),
        ],
        progressLogs: [
          ProgressLog(
            id: 1,
            date: '2026-04-20',
            type: 'Weekly',
            description:
                'Foundation completed, steel framing 60% done. Weather conditions favorable this week.',
            completedTasks: [
              'Foundation concrete pour completed',
              'Steel beam installation level 1-3',
              'Electrical conduit installation started',
              'Plumbing rough-in for ground floor',
            ],
            issues: [
              'Delay in steel delivery by 2 days',
              'Minor equipment malfunction - resolved',
            ],
          ),
        ],
        issues: [
          Issue(
            id: 1,
            title: 'Steel beam shortage',
            type: 'Shortage',
            description:
                'Need 50 more steel beams for upper floors. Current supplier cannot deliver until next week.',
            status: 'Open',
            reportedDate: '2026-04-22',
            reportedBy: 'Juan Dela Cruz',
            priority: 'High',
          ),
        ],
        comments: [
          Comment(
            id: 1,
            author: 'Admin',
            content:
                'Please prioritize steel beam procurement for next week. Check with alternative suppliers.',
            timestamp: '2026-04-23 10:30 AM',
          ),
        ],
      ),
      // Add more sample projects as needed
    ];
    if (notify) notifyListeners();
  }
}
