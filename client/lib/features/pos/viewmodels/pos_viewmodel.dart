import 'package:flutter/foundation.dart';
import '../../../data/models/product.dart';
import '../models/cart_item.dart';
import '../models/transaction.dart';

class POSViewModel extends ChangeNotifier {
  List<CartItem> _cart = [];
  List<Product> _products = [];
  List<Transaction> _transactions = [];
  String _searchQuery = '';
  bool _showReceipt = false;

  // Getters
  List<CartItem> get cart => _cart;
  List<Product> get products => _products;
  List<Transaction> get transactions => _transactions;
  String get searchQuery => _searchQuery;
  bool get showReceipt => _showReceipt;

  List<Product> get filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products.where((product) {
      return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  int get cartItemCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _cart.fold(0.0, (sum, item) => sum + item.subtotal);

  double get tax => subtotal * 0.12; // 12% VAT

  double get total => subtotal + tax;

  // Actions
  void setProducts(List<Product> products) {
    _products = products;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addToCart(Product product) {
    // Check if product has stock
    if (product.stock <= 0) {
      return; // Can't add out of stock items
    }

    final existingIndex = _cart.indexWhere((item) => item.productId == product.id);

    if (existingIndex != -1) {
      // Product already in cart, increment quantity
      if (_cart[existingIndex].quantity < product.stock) {
        _cart[existingIndex].quantity++;
      }
    } else {
      // Add new item to cart
      _cart.add(CartItem(
        productId: product.id,
        name: product.name,
        price: product.sellingPrice,
        category: product.category,
        quantity: 1,
      ));
    }
    notifyListeners();
  }

  void updateQuantity(int productId, int change) {
    final index = _cart.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      final newQuantity = _cart[index].quantity + change;

      // Get product to check stock
      final product = _products.firstWhere((p) => p.id == productId);

      if (newQuantity > 0 && newQuantity <= product.stock) {
        _cart[index].quantity = newQuantity;
      } else if (newQuantity <= 0) {
        _cart.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeFromCart(int productId) {
    _cart.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  Future<void> processPayment(String paymentMethod) async {
    if (_cart.isEmpty) return;

    // Create transaction
    final transaction = Transaction(
      id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      itemsCount: cartItemCount,
      total: total,
      paymentMethod: paymentMethod,
      items: _cart.map((item) => TransactionItem(
        name: item.name,
        quantity: item.quantity,
        price: item.price,
      )).toList(),
    );

    // Add to transactions list
    _transactions.insert(0, transaction);

    // Update product stock
    for (var cartItem in _cart) {
      final productIndex = _products.indexWhere((p) => p.id == cartItem.productId);
      if (productIndex != -1) {
        final product = _products[productIndex];
        _products[productIndex] = product.copyWith(
          stock: product.stock - cartItem.quantity,
        );
      }
    }

    // Show receipt
    _showReceipt = true;
    notifyListeners();

    // Hide receipt and clear cart after 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    _showReceipt = false;
    clearCart();
  }

  void loadTransactions(List<Transaction> transactions) {
    _transactions = transactions;
    notifyListeners();
  }
}
