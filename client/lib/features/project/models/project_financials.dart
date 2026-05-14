class ProjectFinancials {
  final double totalBudget;
  final double totalPlanned;
  final double totalActual;
  final double remaining;
  final int progress;

  ProjectFinancials({
    required this.totalBudget,
    required this.totalPlanned,
    required this.totalActual,
    required this.remaining,
    required this.progress,
  });

  factory ProjectFinancials.fromJson(Map<String, dynamic> json) {
    return ProjectFinancials(
      totalBudget: json['totalBudget'].toDouble(),
      totalPlanned: json['totalPlanned'].toDouble(),
      totalActual: json['totalActual'].toDouble(),
      remaining: json['remaining'].toDouble(),
      progress: json['progress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBudget': totalBudget,
      'totalPlanned': totalPlanned,
      'totalActual': totalActual,
      'remaining': remaining,
      'progress': progress,
    };
  }
}
