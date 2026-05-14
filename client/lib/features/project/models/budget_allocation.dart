class BudgetAllocation {
  final double materials;
  final double labor;
  final double equipment;

  BudgetAllocation({
    required this.materials,
    required this.labor,
    required this.equipment,
  });

  double get total => materials + labor + equipment;

  factory BudgetAllocation.fromJson(Map<String, dynamic> json) {
    return BudgetAllocation(
      materials: json['materials'].toDouble(),
      labor: json['labor'].toDouble(),
      equipment: json['equipment'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materials': materials,
      'labor': labor,
      'equipment': equipment,
    };
  }
}
