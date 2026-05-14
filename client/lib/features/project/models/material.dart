class Material {
  final int id;
  final String name;
  final String category;
  final int quantityRequired;
  final int quantityReceived;
  final int used;
  final int available;
  final double unitCost;
  final String unit;
  final String status; // 'OK' | 'LOW' | 'OUT'

  Material({
    required this.id,
    required this.name,
    required this.category,
    required this.quantityRequired,
    required this.quantityReceived,
    required this.used,
    required this.available,
    required this.unitCost,
    required this.unit,
    required this.status,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      quantityRequired: json['quantityRequired'],
      quantityReceived: json['quantityReceived'],
      used: json['used'],
      available: json['available'],
      unitCost: json['unitCost'].toDouble(),
      unit: json['unit'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantityRequired': quantityRequired,
      'quantityReceived': quantityReceived,
      'used': used,
      'available': available,
      'unitCost': unitCost,
      'unit': unit,
      'status': status,
    };
  }
}
