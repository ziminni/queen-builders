class WbsMaterialLine {
  final int id;
  final String name;
  final double quantity;
  final String unitType;
  final double unitCost;
  final String? supplier;

  /// 0–100; used when syncing category progress from materials.
  final int completionPercent;

  const WbsMaterialLine({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitType,
    required this.unitCost,
    this.supplier,
    this.completionPercent = 0,
  });

  double get lineTotal => quantity * unitCost;

  WbsMaterialLine copyWith({
    int? id,
    String? name,
    double? quantity,
    String? unitType,
    double? unitCost,
    String? supplier,
    bool clearSupplier = false,
    int? completionPercent,
  }) {
    return WbsMaterialLine(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitType: unitType ?? this.unitType,
      unitCost: unitCost ?? this.unitCost,
      supplier: clearSupplier ? null : (supplier ?? this.supplier),
      completionPercent: completionPercent ?? this.completionPercent,
    );
  }
}
