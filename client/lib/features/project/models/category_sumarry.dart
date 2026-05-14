class CategorySummary {
  final String category; // 'Materials' | 'Labor' | 'Equipment' | 'Permits' | 'Misc'
  final double planned;
  final double actual;
  final double variance;
  final String status; // 'safe' | 'warning' | 'critical'

  CategorySummary({
    required this.category,
    required this.planned,
    required this.actual,
    required this.variance,
    required this.status,
  });

  factory CategorySummary.fromJson(Map<String, dynamic> json) {
    return CategorySummary(
      category: json['category'],
      planned: json['planned'].toDouble(),
      actual: json['actual'].toDouble(),
      variance: json['variance'].toDouble(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'planned': planned,
      'actual': actual,
      'variance': variance,
      'status': status,
    };
  }
}
