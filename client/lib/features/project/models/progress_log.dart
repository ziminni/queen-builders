class ProgressLog {
  final int id;
  final String date;
  final String type; // 'Daily' | 'Weekly'
  final String description;
  final List<String> completedTasks;
  final List<String> issues;
  final List<String>? attachments;

  ProgressLog({
    required this.id,
    required this.date,
    required this.type,
    required this.description,
    required this.completedTasks,
    required this.issues,
    this.attachments,
  });

  factory ProgressLog.fromJson(Map<String, dynamic> json) {
    return ProgressLog(
      id: json['id'],
      date: json['date'],
      type: json['type'],
      description: json['description'],
      completedTasks: List<String>.from(json['completedTasks']),
      issues: List<String>.from(json['issues']),
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'type': type,
      'description': description,
      'completedTasks': completedTasks,
      'issues': issues,
      'attachments': attachments,
    };
  }
}
