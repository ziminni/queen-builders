class Issue {
  final int id;
  final String title;
  final String type; // 'Delay' | 'Shortage' | 'Accident' | 'Other'
  final String description;
  final String status; // 'Open' | 'In Progress' | 'Resolved'
  final String reportedDate;
  final String reportedBy;
  final String priority; // 'Low' | 'Medium' | 'High'

  Issue({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.status,
    required this.reportedDate,
    required this.reportedBy,
    required this.priority,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      description: json['description'],
      status: json['status'],
      reportedDate: json['reportedDate'],
      reportedBy: json['reportedBy'],
      priority: json['priority'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'description': description,
      'status': status,
      'reportedDate': reportedDate,
      'reportedBy': reportedBy,
      'priority': priority,
    };
  }
}
