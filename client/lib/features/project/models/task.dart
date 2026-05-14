class Task {
  final String id;
  final int projectId;
  final String name;
  final String wbs;
  final String? parentId;
  final String startDate;
  final String endDate;
  final int progress;
  final String? category; // 'Materials' | 'Labor' | 'Equipment' | 'Permits' | 'Misc'
  final List<String> dependencies;
  final bool isMilestone;

  /// Whole-number WBS row (e.g. `1`, `2`) — schedule category shown at full rolled-up %.
  /// Decimals (`1.1`, `2.2`) are work packages under that category.
  final bool isSummary;

  Task({
    required this.id,
    required this.projectId,
    required this.name,
    required this.wbs,
    this.parentId,
    required this.startDate,
    required this.endDate,
    required this.progress,
    this.category,
    required this.dependencies,
    required this.isMilestone,
    this.isSummary = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      projectId: json['projectId'],
      name: json['name'],
      wbs: json['wbs'],
      parentId: json['parentId'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      progress: json['progress'],
      category: json['category'],
      dependencies: List<String>.from(json['dependencies'] ?? []),
      isMilestone: json['isMilestone'],
      isSummary: json['isSummary'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'wbs': wbs,
      'parentId': parentId,
      'startDate': startDate,
      'endDate': endDate,
      'progress': progress,
      'category': category,
      'dependencies': dependencies,
      'isMilestone': isMilestone,
      'isSummary': isSummary,
    };
  }
}
