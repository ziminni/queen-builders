class Product {
  final int id;
  final String itemCode;
  final String name;
  final String description;
  final String category;
  final String subcategory;
  final String brand;
  final String specifications;
  final String unit;
  final double costPrice;
  final double markupPercent;
  final double sellingPrice;
  final int stock;
  final int reorderLevel;
  final int reorderQuantity;
  final String supplier;
  final String? supplierCode;
  final String? batchNumber;
  final String? expiryDate;
  final String? location;
  final String? barcode;
  final bool taxable;

  Product({
    required this.id,
    required this.itemCode,
    required this.name,
    required this.description,
    required this.category,
    required this.subcategory,
    required this.brand,
    required this.specifications,
    required this.unit,
    required this.costPrice,
    required this.markupPercent,
    required this.sellingPrice,
    required this.stock,
    required this.reorderLevel,
    required this.reorderQuantity,
    required this.supplier,
    this.supplierCode,
    this.batchNumber,
    this.expiryDate,
    this.location,
    this.barcode,
    required this.taxable,
  });

  /// Get the stock status based on current stock levels
  StockStatus get stockStatus {
    if (stock <= reorderLevel * 0.1) return StockStatus.critical;
    if (stock <= reorderLevel) return StockStatus.low;
    return StockStatus.ok;
  }

  /// Calculate profit margin
  double get profitMargin => sellingPrice - costPrice;

  /// Calculate profit percentage
  double get profitPercentage => (profitMargin / costPrice) * 100;

  /// Check if stock is below reorder level
  bool get needsReorder => stock <= reorderLevel;

  /// Get quantity needed to reach reorder quantity
  int get quantityToReorder {
    if (!needsReorder) return 0;
    return reorderQuantity;
  }

  /// Create Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      itemCode: json['itemCode'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String,
      brand: json['brand'] as String,
      specifications: json['specifications'] as String,
      unit: json['unit'] as String,
      costPrice: (json['costPrice'] as num).toDouble(),
      markupPercent: (json['markupPercent'] as num).toDouble(),
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      stock: json['stock'] as int,
      reorderLevel: json['reorderLevel'] as int,
      reorderQuantity: json['reorderQuantity'] as int,
      supplier: json['supplier'] as String,
      supplierCode: json['supplierCode'] as String?,
      batchNumber: json['batchNumber'] as String?,
      expiryDate: json['expiryDate'] as String?,
      location: json['location'] as String?,
      barcode: json['barcode'] as String?,
      taxable: json['taxable'] as bool,
    );
  }

  /// Convert Product to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemCode': itemCode,
      'name': name,
      'description': description,
      'category': category,
      'subcategory': subcategory,
      'brand': brand,
      'specifications': specifications,
      'unit': unit,
      'costPrice': costPrice,
      'markupPercent': markupPercent,
      'sellingPrice': sellingPrice,
      'stock': stock,
      'reorderLevel': reorderLevel,
      'reorderQuantity': reorderQuantity,
      'supplier': supplier,
      'supplierCode': supplierCode,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate,
      'location': location,
      'barcode': barcode,
      'taxable': taxable,
    };
  }

  /// Create a copy with modified fields
  Product copyWith({
    int? id,
    String? itemCode,
    String? name,
    String? description,
    String? category,
    String? subcategory,
    String? brand,
    String? specifications,
    String? unit,
    double? costPrice,
    double? markupPercent,
    double? sellingPrice,
    int? stock,
    int? reorderLevel,
    int? reorderQuantity,
    String? supplier,
    String? supplierCode,
    String? batchNumber,
    String? expiryDate,
    String? location,
    String? barcode,
    bool? taxable,
  }) {
    return Product(
      id: id ?? this.id,
      itemCode: itemCode ?? this.itemCode,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      brand: brand ?? this.brand,
      specifications: specifications ?? this.specifications,
      unit: unit ?? this.unit,
      costPrice: costPrice ?? this.costPrice,
      markupPercent: markupPercent ?? this.markupPercent,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stock: stock ?? this.stock,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      reorderQuantity: reorderQuantity ?? this.reorderQuantity,
      supplier: supplier ?? this.supplier,
      supplierCode: supplierCode ?? this.supplierCode,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      location: location ?? this.location,
      barcode: barcode ?? this.barcode,
      taxable: taxable ?? this.taxable,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, itemCode: $itemCode, name: $name, stock: $stock)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Stock status enumeration
enum StockStatus {
  ok,
  low,
  critical;

  /// Get display label
  String get label {
    switch (this) {
      case StockStatus.ok:
        return 'OK';
      case StockStatus.low:
        return 'LOW';
      case StockStatus.critical:
        return 'CRITICAL';
    }
  }

  /// Get status description
  String get description {
    switch (this) {
      case StockStatus.ok:
        return 'Stock levels are healthy';
      case StockStatus.low:
        return 'Stock is below reorder level';
      case StockStatus.critical:
        return 'Critical stock level - reorder immediately';
    }
  }
}
