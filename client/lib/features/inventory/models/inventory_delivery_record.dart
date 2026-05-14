class InventoryDeliveryRecord {
  final DateTime receivedAt;
  final String supplierName;
  final String warehouseLocation;
  final String receivedBy;
  final int lineCount;
  final int totalUnits;

  const InventoryDeliveryRecord({
    required this.receivedAt,
    required this.supplierName,
    required this.warehouseLocation,
    this.receivedBy = '',
    required this.lineCount,
    required this.totalUnits,
  });

  factory InventoryDeliveryRecord.fromJson(Map<String, dynamic> json) {
    return InventoryDeliveryRecord(
      receivedAt: DateTime.parse(json['receivedAt'] as String),
      supplierName: json['supplierName'] as String? ?? '',
      warehouseLocation: json['warehouseLocation'] as String? ?? '',
      receivedBy: json['receivedBy'] as String? ?? '',
      lineCount: json['lineCount'] as int,
      totalUnits: json['totalUnits'] as int,
    );
  }
}
