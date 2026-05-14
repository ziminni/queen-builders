class Transaction {
  final String id;
  final DateTime timestamp;
  final int itemsCount;
  final double total;
  final String paymentMethod;
  final List<TransactionItem> items;
  /// When true, sale is recorded as collectible / "utang" (pay-later).
  final bool isPayLater;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;

  Transaction({
    required this.id,
    required this.timestamp,
    required this.itemsCount,
    required this.total,
    required this.paymentMethod,
    required this.items,
    this.isPayLater = false,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'items': itemsCount,
      'total': total,
      'paymentMethod': paymentMethod,
      'itemDetails': items.map((item) => item.toJson()).toList(),
      'isPayLater': isPayLater,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    final id = idRaw is String ? idRaw : idRaw.toString();
    return Transaction(
      id: id,
      timestamp: DateTime.parse(json['timestamp'] as String),
      itemsCount: json['items'] as int,
      total: (json['total'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      items: (json['itemDetails'] as List<dynamic>? ?? [])
          .map((item) => TransactionItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      isPayLater: json['isPayLater'] as bool? ?? false,
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      customerAddress: json['customerAddress'] as String?,
    );
  }
}

class TransactionItem {
  final String name;
  final int quantity;
  final double price;

  TransactionItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }
}
