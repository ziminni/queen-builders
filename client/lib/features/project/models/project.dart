import 'material.dart';
import 'budget_allocation.dart';
import 'expense.dart';
import 'progress_log.dart';
import 'issue.dart';
import 'comment.dart';

class Project {
  final int id;
  final String name;
  final String client;
  final String foreman;
  final String status; // 'In Progress' | 'Planning' | 'On Hold' | 'Completed'
  final String location;
  final int progress;
  final BudgetAllocation budgetAllocated;
  final String startDate;
  final String deadline;
  final List<Material> materials;
  final List<Expense> expenses;
  final List<ProgressLog> progressLogs;
  final List<Issue> issues;
  final List<Comment> comments;

  Project({
    required this.id,
    required this.name,
    required this.client,
    required this.foreman,
    required this.status,
    required this.location,
    required this.progress,
    required this.budgetAllocated,
    required this.startDate,
    required this.deadline,
    required this.materials,
    required this.expenses,
    required this.progressLogs,
    required this.issues,
    required this.comments,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      client: json['client'],
      foreman: json['foreman'],
      status: json['status'],
      location: json['location'],
      progress: json['progress'],
      budgetAllocated: BudgetAllocation.fromJson(json['budgetAllocated']),
      startDate: json['startDate'],
      deadline: json['deadline'],
      materials: (json['materials'] as List)
          .map((m) => Material.fromJson(m))
          .toList(),
      expenses: (json['expenses'] as List)
          .map((e) => Expense.fromJson(e))
          .toList(),
      progressLogs: (json['progressLogs'] as List)
          .map((p) => ProgressLog.fromJson(p))
          .toList(),
      issues: (json['issues'] as List)
          .map((i) => Issue.fromJson(i))
          .toList(),
      comments: (json['comments'] as List)
          .map((c) => Comment.fromJson(c))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'client': client,
      'foreman': foreman,
      'status': status,
      'location': location,
      'progress': progress,
      'budgetAllocated': budgetAllocated.toJson(),
      'startDate': startDate,
      'deadline': deadline,
      'materials': materials.map((m) => m.toJson()).toList(),
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'progressLogs': progressLogs.map((p) => p.toJson()).toList(),
      'issues': issues.map((i) => i.toJson()).toList(),
      'comments': comments.map((c) => c.toJson()).toList(),
    };
  }
}
