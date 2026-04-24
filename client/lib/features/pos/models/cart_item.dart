class CartItem {
  final int productId;
  final String name;
  final double price;
  final String category;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.category,
    this.quantity = 1,
  });

  double get subtotal => price * quantity;

  CartItem copyWith({
    int? productId,
    String? name,
    double? price,
    String? category,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'category': category,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      quantity: json['quantity'] as int,
    );
  }

  @override
  String toString() {
    return 'CartItem(productId: $productId, name: $name, quantity: $quantity, subtotal: \$${subtotal.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.productId == productId;
  }

  @override
  int get hashCode => productId.hashCode;
}
