import 'wbs_material_line.dart';

/// Construction work breakdown category (WBS line).
class WorkBreakdownCategory {
  final int id;
  final String categoryName;
  final String? description;
  final double assignedBudget;
  final int progressPercentage;

  /// Not Started | Ongoing | Completed
  final String status;
  final List<WbsMaterialLine> materials;

  const WorkBreakdownCategory({
    required this.id,
    required this.categoryName,
    this.description,
    required this.assignedBudget,
    required this.progressPercentage,
    required this.status,
    this.materials = const [],
  });

  double get totalMaterialCost =>
      materials.fold(0.0, (sum, m) => sum + m.lineTotal);

  bool get isOverBudget =>
      assignedBudget > 0 && totalMaterialCost > assignedBudget;

  WorkBreakdownCategory copyWith({
    int? id,
    String? categoryName,
    String? description,
    bool clearDescription = false,
    double? assignedBudget,
    int? progressPercentage,
    String? status,
    List<WbsMaterialLine>? materials,
  }) {
    return WorkBreakdownCategory(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      description: clearDescription ? null : (description ?? this.description),
      assignedBudget: assignedBudget ?? this.assignedBudget,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      status: status ?? this.status,
      materials: materials ?? this.materials,
    );
  }
}
