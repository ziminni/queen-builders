class Transaction {
  final String id;
  final DateTime timestamp;
  final int itemsCount;
  final double total;
  final String paymentMethod;
  final List<TransactionItem> items;

  Transaction({
    required this.id,
    required this.timestamp,
    required this.itemsCount,
    required this.total,
    required this.paymentMethod,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'items': itemsCount,
      'total': total,
      'paymentMethod': paymentMethod,
      'itemDetails': items.map((item) => item.toJson()).toList(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      itemsCount: json['items'] as int,
      total: (json['total'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      items: (json['itemDetails'] as List<dynamic>? ?? [])
          .map((item) => TransactionItem.fromJson(item as Map<String, dynamic>))
          .toList(),
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
