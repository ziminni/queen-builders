import 'package:flutter/foundation.dart';
import '../../../core/audit/audit_log_viewmodel.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/inventory_repository.dart';
import '../../inventory/viewmodels/inventory_viewmodel.dart';
import '../models/cart_item.dart';
import '../models/sample_products.dart';
import '../models/transaction.dart';

class POSViewModel extends ChangeNotifier {
  POSViewModel({
    AuditLogViewModel? auditLog,
    InventoryRepository? inventoryRepository,
    InventoryViewModel? inventoryViewModel,
  }) : _auditLog = auditLog,
       _inventoryRepository = inventoryRepository ?? InventoryRepository(),
       _inventoryViewModel = inventoryViewModel;

  final AuditLogViewModel? _auditLog;
  final InventoryRepository _inventoryRepository;
  final InventoryViewModel? _inventoryViewModel;

  final List<CartItem> _cart = [];
  List<Product> _products = [];
  List<Transaction> _transactions = [];
  String _searchQuery = '';

  /// When non-null, only products in this category are listed.
  String? _categoryFilter;

  bool catalogLoading = false;
  String? catalogError;

  // Getters
  List<CartItem> get cart => _cart;
  List<Product> get products => _products;
  List<Transaction> get transactions => _transactions;

  /// Pay-later / utang sales only.
  List<Transaction> get collectibles =>
      _transactions.where((t) => t.isPayLater).toList();
  List<Transaction> get pendingCollectibles =>
      collectibles.where((t) => !t.isCollectiblePaid).toList();
  List<Transaction> get paidCollectibles =>
      collectibles.where((t) => t.isCollectiblePaid).toList();
  String get searchQuery => _searchQuery;
  String? get categoryFilter => _categoryFilter;

  /// Distinct categories from loaded products, sorted alphabetically.
  List<String> get productCategories {
    final set = <String>{};
    for (final p in _products) {
      if (p.category.trim().isNotEmpty) {
        set.add(p.category);
      }
    }
    final list = set.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  List<Product> get filteredProducts {
    Iterable<Product> list = _products;
    final cat = _categoryFilter;
    if (cat != null && cat.isNotEmpty) {
      list = list.where((p) => p.category == cat);
    }
    if (_searchQuery.isEmpty) return list.toList();
    final q = _searchQuery.toLowerCase();
    return list.where((product) {
      return product.name.toLowerCase().contains(q) ||
          product.category.toLowerCase().contains(q);
    }).toList();
  }

  int get cartItemCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _cart.fold(0.0, (sum, item) => sum + item.subtotal);

  double get tax => subtotal * 0.12; // 12% VAT (must match server)

  double get total => subtotal + tax;

  /// Loads product grid from the same inventory API as Inventory.
  Future<void> loadPosCatalog({bool useSampleFallback = true}) async {
    catalogError = null;
    catalogLoading = true;
    notifyListeners();
    try {
      final list = await _inventoryRepository.fetchProducts();
      _products = list;
      catalogError = null;
    } catch (e) {
      catalogError = e.toString();
      if (useSampleFallback && _products.isEmpty) {
        _products = List<Product>.from(getSamplePOSProducts());
      }
    } finally {
      catalogLoading = false;
      notifyListeners();
    }
  }

  /// Recent sales persisted on the server (same rows as inventory POS module).
  Future<void> loadSalesHistory() async {
    try {
      final raw = await _inventoryRepository.fetchPosSalesRaw();
      _transactions = raw.map((m) => Transaction.fromJson(m)).toList();
      notifyListeners();
    } catch (_) {
      // Keep in-memory session history if API unavailable.
    }
  }

  // Actions
  void setProducts(List<Product> products) {
    _products = products;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    if (_categoryFilter == category) return;
    _categoryFilter = category;
    notifyListeners();
  }

  void addToCart(Product product) {
    if (product.stock <= 0) {
      return;
    }

    final existingIndex = _cart.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingIndex != -1) {
      if (_cart[existingIndex].quantity < product.stock) {
        _cart[existingIndex].quantity++;
      }
    } else {
      _cart.add(
        CartItem(
          productId: product.id,
          name: product.name,
          price: product.sellingPrice,
          category: product.category,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void updateQuantity(int productId, int change) {
    final index = _cart.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      final newQuantity = _cart[index].quantity + change;

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

  Future<void> completeCashSale({
    required String customerName,
    required String customerPhone,
  }) async {
    await _completeSale(
      paymentMethod: 'Cash',
      isPayLater: false,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: null,
    );
  }

  Future<void> completePayLaterSale({
    required String customerName,
    required String customerAddress,
    required String contactNumber,
  }) async {
    await _completeSale(
      paymentMethod: 'Pay-Later (Utang)',
      isPayLater: true,
      customerName: customerName,
      customerPhone: contactNumber,
      customerAddress: customerAddress,
    );
  }

  Future<void> _completeSale({
    required String paymentMethod,
    required bool isPayLater,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
  }) async {
    if (_cart.isEmpty) return;

    final lines = <Map<String, dynamic>>[
      for (final c in _cart) {'productId': c.productId, 'quantity': c.quantity},
    ];

    final res = await _inventoryRepository.checkoutPos(
      lines: lines,
      paymentMethod: paymentMethod,
      isPayLater: isPayLater,
      customerName: customerName ?? '',
      customerPhone: customerPhone ?? '',
      customerAddress: customerAddress ?? '',
    );

    final saleMap = Map<String, dynamic>.from(res['sale'] as Map);
    final transaction = Transaction.fromJson(saleMap);
    _transactions.insert(0, transaction);

    final itemLines = transaction.items
        .map((i) => '${i.name} ×${i.quantity}')
        .join('; ');
    final customerBits = <String>[];
    final cn = customerName;
    if (cn != null && cn.trim().isNotEmpty) {
      customerBits.add('Customer: ${cn.trim()}');
    }
    final cp = customerPhone;
    if (cp != null && cp.trim().isNotEmpty) {
      customerBits.add('Contact: ${cp.trim()}');
    }
    final ca = customerAddress;
    if (ca != null && ca.trim().isNotEmpty) {
      customerBits.add('Address: ${ca.trim()}');
    }
    _auditLog?.record(
      module: AuditLogViewModel.modulePos,
      category: AuditLogViewModel.categorySales,
      summary:
          '${isPayLater ? 'Pay-later (utang)' : 'Cash'} checkout · ${transaction.id} · ₱${transaction.total.toStringAsFixed(2)} · ${transaction.itemsCount} pc(s)',
      detail: [
        'Payment: $paymentMethod',
        'Items: $itemLines',
        if (customerBits.isNotEmpty) customerBits.join(' · '),
      ].join('\n'),
    );

    final refreshed = await _inventoryRepository.fetchProducts();
    _products = refreshed;
    _inventoryViewModel?.replaceCatalog(refreshed);

    clearCart();
    notifyListeners();
  }

  Future<Transaction> markCollectiblePaid(Transaction transaction) async {
    if (!transaction.isPayLater || transaction.isCollectiblePaid) {
      return transaction;
    }

    final id = _serverIdFor(transaction.id);
    if (id == null) {
      throw StateError('Cannot update sale ${transaction.id}.');
    }

    final res = await _inventoryRepository.markPosSalePaid(id);
    final saleMap = Map<String, dynamic>.from(res['sale'] as Map);
    final updated = Transaction.fromJson(saleMap);
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index == -1) {
      _transactions.insert(0, updated);
    } else {
      _transactions[index] = updated;
    }
    _auditLog?.record(
      module: AuditLogViewModel.modulePos,
      category: AuditLogViewModel.categorySales,
      summary:
          'Collectible paid · ${updated.id} · ₱${updated.total.toStringAsFixed(2)}',
      detail: [
        'Customer: ${updated.customerName ?? 'Walk-in'}',
        if ((updated.customerPhone ?? '').isNotEmpty)
          'Contact: ${updated.customerPhone}',
      ].join('\n'),
    );
    notifyListeners();
    return updated;
  }

  int? _serverIdFor(String transactionId) {
    final cleaned = transactionId.startsWith('POS-')
        ? transactionId.substring(4)
        : transactionId;
    return int.tryParse(cleaned);
  }

  void loadTransactions(List<Transaction> transactions) {
    _transactions = transactions;
    notifyListeners();
  }
}
