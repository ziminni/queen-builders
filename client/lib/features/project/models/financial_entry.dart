class FinancialEntry {
  final String id;
  final int projectId;
  final String date;
  final String? taskId;
  final String? taskName;
  final String category; // 'Materials' | 'Labor' | 'Equipment' | 'Permits' | 'Misc'
  final String description;
  final double plannedCost;
  final double actualCost;
  final String notes;

  FinancialEntry({
    required this.id,
    required this.projectId,
    required this.date,
    this.taskId,
    this.taskName,
    required this.category,
    required this.description,
    required this.plannedCost,
    required this.actualCost,
    required this.notes,
  });

  factory FinancialEntry.fromJson(Map<String, dynamic> json) {
    return FinancialEntry(
      id: json['id'],
      projectId: json['projectId'],
      date: json['date'],
      taskId: json['taskId'],
      taskName: json['taskName'],
      category: json['category'],
      description: json['description'],
      plannedCost: json['plannedCost'].toDouble(),
      actualCost: json['actualCost'].toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'date': date,
      'taskId': taskId,
      'taskName': taskName,
      'category': category,
      'description': description,
      'plannedCost': plannedCost,
      'actualCost': actualCost,
      'notes': notes,
    };
  }
}
