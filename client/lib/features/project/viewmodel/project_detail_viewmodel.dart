import 'package:flutter/material.dart';

import '../models/financial_entry.dart';
import '../models/task.dart';
import '../models/wbs_material_line.dart';
import '../models/work_breakdown_category.dart';

class ProjectMetrics {
  final double totalPlanned;
  final double totalActual;
  final double remaining;
  final int progress;

  ProjectMetrics({
    required this.totalPlanned,
    required this.totalActual,
    required this.remaining,
    required this.progress,
  });
}

class ProjectDetailViewModel extends ChangeNotifier {
  ProjectDetailViewModel(this.projectId, {required this.totalAllocatedBudget}) {
    loadData();
  }

  final int projectId;
  final double totalAllocatedBudget;

  String _activeTab = 'overview';
  List<FinancialEntry> _entries = [];
  List<Task> _tasks = [];
  List<WorkBreakdownCategory> _workCategories = [];
  String _wbsSearchQuery = '';

  int _nextEntityId = 1;

  String get activeTab => _activeTab;
  List<FinancialEntry> get entries => _entries;
  List<Task> get tasks => _tasks;
  List<WorkBreakdownCategory> get workCategories =>
      List.unmodifiable(_workCategories);
  String get wbsSearchQuery => _wbsSearchQuery;

  List<WorkBreakdownCategory> get filteredWorkCategories {
    final q = _wbsSearchQuery.trim().toLowerCase();
    if (q.isEmpty) return List<WorkBreakdownCategory>.from(_workCategories);
    return _workCategories.where((c) {
      final name = c.categoryName.toLowerCase();
      final desc = (c.description ?? '').toLowerCase();
      return name.contains(q) || desc.contains(q);
    }).toList();
  }

  double get wbsTotalMaterialCost =>
      _workCategories.fold(0.0, (sum, c) => sum + c.totalMaterialCost);

  double get wbsTotalAssignedBudget =>
      _workCategories.fold(0.0, (sum, c) => sum + c.assignedBudget);

  /// Until planned-vs-actual cost tracking lands, overall WBS progress stays at 0.
  int get wbsOverallProgressPercent => 0;

  /// Completed phases only via explicit status (not manual progress %).
  int get completedWorkCategoriesCount =>
      _workCategories.where((c) => c.status == 'Completed').length;

  double get wbsBudgetUtilizationPercent {
    if (totalAllocatedBudget <= 0) return 0;
    final used =
        _entries.fold(0.0, (s, e) => s + e.actualCost) + wbsTotalMaterialCost;
    return (used / totalAllocatedBudget * 100).clamp(0, double.infinity);
  }

  bool get hasBudgetOverrun {
    if (totalAllocatedBudget <= 0) return false;
    final used =
        _entries.fold(0.0, (s, e) => s + e.actualCost) + wbsTotalMaterialCost;
    return used > totalAllocatedBudget;
  }

  void setActiveTab(String tab) {
    _activeTab = tab;
    notifyListeners();
  }

  void setWbsSearchQuery(String query) {
    _wbsSearchQuery = query;
    notifyListeners();
  }

  void loadData() {
    _entries = [];
    _tasks = [];
    _workCategories = [];
    _nextEntityId = 1;
    notifyListeners();
  }

  int _allocId() => _nextEntityId++;

  void addWorkCategory(WorkBreakdownCategory category) {
    _workCategories = [..._workCategories, category];
    notifyListeners();
  }

  void updateWorkCategory(WorkBreakdownCategory updated) {
    _workCategories = _workCategories
        .map((c) => c.id == updated.id ? updated : c)
        .toList();
    notifyListeners();
  }

  void removeWorkCategory(int categoryId) {
    _workCategories = _workCategories.where((c) => c.id != categoryId).toList();
    notifyListeners();
  }

  void addMaterial(int categoryId, WbsMaterialLine material) {
    _workCategories = _workCategories.map((c) {
      if (c.id != categoryId) return c;
      return c.copyWith(materials: [...c.materials, material]);
    }).toList();
    notifyListeners();
  }

  void updateMaterial(int categoryId, WbsMaterialLine updated) {
    _workCategories = _workCategories.map((c) {
      if (c.id != categoryId) return c;
      return c.copyWith(
        materials: c.materials
            .map((m) => m.id == updated.id ? updated : m)
            .toList(),
      );
    }).toList();
    notifyListeners();
  }

  void removeMaterial(int categoryId, int materialId) {
    _workCategories = _workCategories.map((c) {
      if (c.id != categoryId) return c;
      return c.copyWith(
        materials: c.materials.where((m) => m.id != materialId).toList(),
      );
    }).toList();
    notifyListeners();
  }

  WorkBreakdownCategory newCategoryDraft({
    required String categoryName,
    String? description,
    double assignedBudget = 0,
    String status = 'Not Started',
  }) {
    return WorkBreakdownCategory(
      id: _allocId(),
      categoryName: categoryName,
      description: description,
      assignedBudget: assignedBudget,
      progressPercentage: 0,
      status: status,
      materials: const [],
    );
  }

  WbsMaterialLine newMaterialDraft({
    required String name,
    double quantity = 1,
    String unitType = 'pcs',
    double unitCost = 0,
    String? supplier,
    int completionPercent = 0,
  }) {
    return WbsMaterialLine(
      id: _allocId(),
      name: name,
      quantity: quantity,
      unitType: unitType,
      unitCost: unitCost,
      supplier: supplier,
      completionPercent: completionPercent.clamp(0, 100),
    );
  }

  ProjectMetrics calculateMetrics(double totalBudget) {
    final entriesPlanned = _entries.fold(0.0, (sum, e) => sum + e.plannedCost);
    final entriesActual = _entries.fold(0.0, (sum, e) => sum + e.actualCost);
    final wbsSpend = wbsTotalMaterialCost;
    final totalActual = entriesActual + wbsSpend;
    final totalPlanned =
        entriesPlanned +
        _workCategories.fold(0.0, (s, c) => s + c.assignedBudget);
    final remaining = totalBudget - totalActual;

    int progress = 0;
    if (_workCategories.isNotEmpty) {
      progress = wbsOverallProgressPercent;
    } else if (_tasks.isNotEmpty) {
      final totalDuration = _tasks.fold(0.0, (sum, t) {
        final start = DateTime.parse(t.startDate);
        final end = DateTime.parse(t.endDate);
        return sum + end.difference(start).inMilliseconds.toDouble();
      });

      final weightedProgress = _tasks.fold(0.0, (sum, t) {
        final start = DateTime.parse(t.startDate);
        final end = DateTime.parse(t.endDate);
        final duration = end.difference(start).inMilliseconds.toDouble();
        final weight = totalDuration > 0 ? duration / totalDuration : 0;
        return sum + (t.progress * weight);
      });

      progress = weightedProgress.round();
    }

    return ProjectMetrics(
      totalPlanned: totalPlanned,
      totalActual: totalActual,
      remaining: remaining,
      progress: progress.clamp(0, 100),
    );
  }
}
