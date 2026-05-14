import 'package:flutter/foundation.dart';

import '../../../core/audit/audit_log_viewmodel.dart';
import '../../../data/models/product.dart';
import '../../../data/models/supplier.dart';
import '../../../data/repositories/inventory_repository.dart';
import '../models/inventory_delivery_record.dart';
import '../models/new_product.dart';
import '../models/sample_products.dart';
import '../models/supplier_delivery_item.dart';

class InventoryViewModel extends ChangeNotifier {
  InventoryViewModel({
    AuditLogViewModel? auditLog,
    InventoryRepository? repository,
  }) : _auditLog = auditLog,
       _repository = repository ?? InventoryRepository();

  final AuditLogViewModel? _auditLog;
  final InventoryRepository _repository;

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<InventoryDeliveryRecord> _deliveryHistory = [];
  List<Supplier> _suppliers = Suppliers.all;
  String _searchQuery = '';
  String _selectedCategory = '';
  String _selectedBrand = '';
  String _selectedStatus = '';
  String _selectedSupplier = '';
  bool _sidebarOpen = true;
  String _activeNav = 'dashboard';

  /// True when the catalog was loaded from [getSampleInventoryProducts] after API failure.
  bool _usingOfflineSample = false;

  bool isLoadingInventory = false;
  String? inventoryError;
  bool isSavingSupplier = false;

  List<Product> get products => _products;
  List<Supplier> get suppliers => List.unmodifiable(_suppliers);
  List<Product> get filteredProducts => _filteredProducts;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedBrand => _selectedBrand;
  String get selectedStatus => _selectedStatus;
  String get selectedSupplier => _selectedSupplier;
  bool get sidebarOpen => _sidebarOpen;
  String get activeNav => _activeNav;
  bool get usingOfflineSample => _usingOfflineSample;

  List<InventoryDeliveryRecord> get deliveryHistory =>
      List.unmodifiable(_deliveryHistory);

  int get lowAndCriticalCount =>
      _products.where((p) => p.stockStatus != StockStatus.ok).length;

  int get totalStockUnits => _products.fold<int>(0, (sum, p) => sum + p.stock);

  double get stockStatusFractionOk {
    if (_products.isEmpty) return 0;
    final n = _products.where((p) => p.stockStatus == StockStatus.ok).length;
    return n / _products.length;
  }

  double get stockStatusFractionLow {
    if (_products.isEmpty) return 0;
    final n = _products.where((p) => p.stockStatus == StockStatus.low).length;
    return n / _products.length;
  }

  double get stockStatusFractionCritical {
    if (_products.isEmpty) return 0;
    final n = _products
        .where((p) => p.stockStatus == StockStatus.critical)
        .length;
    return n / _products.length;
  }

  void initializeProducts(List<Product> products) {
    _products = products;
    _usingOfflineSample = true;
    _applyFilters();
  }

  /// Loads products (and delivery summaries) from the Django API.
  /// On failure, optionally seeds demo data when [useSampleFallback] and the catalog is empty.
  Future<void> loadProductsFromApi({bool useSampleFallback = true}) async {
    inventoryError = null;
    isLoadingInventory = true;
    notifyListeners();
    try {
      final list = await _repository.fetchProducts();
      final deliveries = await _repository.fetchDeliveries();
      _products = list;
      _deliveryHistory = deliveries;
      try {
        final suppliers = await _repository.fetchSuppliers();
        _suppliers = suppliers;
        Suppliers.replaceAll(suppliers);
      } catch (_) {
        _suppliers = Suppliers.all;
      }
      _usingOfflineSample = false;
      inventoryError = null;
    } catch (e) {
      inventoryError = e.toString();
      if (useSampleFallback && _products.isEmpty) {
        _usingOfflineSample = true;
        _products = List<Product>.from(getSampleInventoryProducts());
        _deliveryHistory = [];
        _suppliers = Suppliers.all;
      }
    } finally {
      isLoadingInventory = false;
      _applyFilters();
    }
  }

  Future<void> loadSuppliersFromApi({bool useFallback = true}) async {
    try {
      final suppliers = await _repository.fetchSuppliers();
      _suppliers = suppliers;
      Suppliers.replaceAll(suppliers);
      inventoryError = null;
      notifyListeners();
    } catch (e) {
      inventoryError = e.toString();
      if (useFallback && _suppliers.isEmpty) {
        _suppliers = Suppliers.all;
      }
      notifyListeners();
      if (!useFallback) rethrow;
    }
  }

  Future<void> createSupplier(Supplier supplier) async {
    isSavingSupplier = true;
    inventoryError = null;
    notifyListeners();
    try {
      final saved = await _repository.createSupplier(supplier);
      final updated = [
        ..._suppliers.where(
          (s) => s.code.toLowerCase() != saved.code.toLowerCase(),
        ),
        saved,
      ]..sort((a, b) => a.code.compareTo(b.code));
      _suppliers = updated;
      Suppliers.replaceAll(updated);
      _auditLog?.record(
        module: AuditLogViewModel.moduleInventory,
        category: AuditLogViewModel.categoryReceiving,
        summary: 'Supplier added: ${saved.name} (${saved.code})',
        detail:
            'Terms: ${saved.paymentTerms} · Lead time: ${saved.leadTimeDays} day(s)',
      );
    } catch (e) {
      inventoryError = e.toString();
      rethrow;
    } finally {
      isSavingSupplier = false;
      notifyListeners();
    }
  }

  /// Same catalog as [list] from server (e.g. after POS checkout stocks change).
  void replaceCatalog(List<Product> products) {
    _products = List<Product>.from(products);
    _usingOfflineSample = false;
    inventoryError = null;
    _applyFilters();
    notifyListeners();
  }

  /// Registers a catalog item locally (offline / demo only).
  void addRegisteredProduct(NewProduct n) {
    final nextId = _products.isEmpty
        ? 1
        : _products.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;

    final code = n.itemCode.trim().isEmpty ? 'SKU-$nextId' : n.itemCode.trim();

    final product = Product(
      id: nextId,
      itemCode: code,
      name: n.name.trim(),
      description: n.description.trim(),
      category: n.category.trim(),
      subcategory: n.subcategory.trim(),
      brand: n.brand.trim(),
      specifications: n.specifications.trim(),
      unit: n.unit.trim().isEmpty ? 'unit' : n.unit.trim(),
      costPrice: double.tryParse(n.costPrice) ?? 0,
      markupPercent: double.tryParse(n.markupPercent) ?? 0,
      sellingPrice: double.tryParse(n.sellingPrice) ?? 0,
      stock: 0,
      reorderLevel: 20,
      reorderQuantity: 50,
      supplier: '',
      supplierCode: null,
      batchNumber: null,
      expiryDate: null,
      location: null,
      barcode: null,
      taxable: true,
    );

    _products = [..._products, product];
    _applyFilters();

    _auditLog?.record(
      module: AuditLogViewModel.moduleInventory,
      category: AuditLogViewModel.categoryProductCatalog,
      summary: 'New product registered: ${product.name} (${product.itemCode})',
      detail:
          'Category: ${product.category}${product.brand.isNotEmpty ? ' · Brand: ${product.brand}' : ''}',
    );
  }

  Future<void> commitProductForm(NewProduct n, int? existingProductId) async {
    if (_usingOfflineSample) {
      if (existingProductId == null) {
        addRegisteredProduct(n);
      } else {
        updateProductFromForm(existingProductId, n);
      }
      return;
    }
    try {
      if (existingProductId == null) {
        await _repository.createProduct(n);
        _auditLog?.record(
          module: AuditLogViewModel.moduleInventory,
          category: AuditLogViewModel.categoryProductCatalog,
          summary:
              'New product registered: ${n.name.trim()} (${n.itemCode.trim().isEmpty ? 'auto SKU' : n.itemCode.trim()})',
          detail:
              'Category: ${n.category.trim()}${n.brand.trim().isNotEmpty ? ' · Brand: ${n.brand.trim()}' : ''}',
        );
      } else {
        await _repository.updateProduct(existingProductId, n);
        _auditLog?.record(
          module: AuditLogViewModel.moduleInventory,
          category: AuditLogViewModel.categoryProductCatalog,
          summary: 'Product updated: ${n.name.trim()} (${n.itemCode.trim()})',
          detail:
              'Category: ${n.category.trim()}${n.brand.trim().isNotEmpty ? ' · Brand: ${n.brand.trim()}' : ''}',
        );
      }
      await loadProductsFromApi(useSampleFallback: false);
    } catch (e) {
      inventoryError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void updateProductFromForm(int id, NewProduct n) {
    final idx = _products.indexWhere((p) => p.id == id);
    if (idx < 0) return;
    final p = _products[idx];
    final code = n.itemCode.trim().isEmpty ? p.itemCode : n.itemCode.trim();
    final updated = p.copyWith(
      itemCode: code,
      name: n.name.trim(),
      description: n.description.trim(),
      category: n.category.trim(),
      subcategory: n.subcategory.trim(),
      brand: n.brand.trim(),
      specifications: n.specifications.trim(),
      unit: n.unit.trim().isEmpty ? p.unit : n.unit.trim(),
      costPrice: double.tryParse(n.costPrice) ?? p.costPrice,
      markupPercent: double.tryParse(n.markupPercent) ?? p.markupPercent,
      sellingPrice: double.tryParse(n.sellingPrice) ?? p.sellingPrice,
    );
    final list = [..._products];
    list[idx] = updated;
    _products = list;
    _applyFilters();

    _auditLog?.record(
      module: AuditLogViewModel.moduleInventory,
      category: AuditLogViewModel.categoryProductCatalog,
      summary: 'Product updated: ${updated.name} (${updated.itemCode})',
      detail:
          'Category: ${updated.category}${updated.brand.isNotEmpty ? ' · Brand: ${updated.brand}' : ''}',
    );
  }

  Future<void> deleteProduct(int id) async {
    final removed = _productById(id);
    if (_usingOfflineSample) {
      _products = _products.where((p) => p.id != id).toList();
      _applyFilters();
      if (removed != null) {
        _auditLog?.record(
          module: AuditLogViewModel.moduleInventory,
          category: AuditLogViewModel.categoryProductCatalog,
          summary: 'Product removed: ${removed.name} (${removed.itemCode})',
          detail: 'Category: ${removed.category}',
        );
      }
      return;
    }
    try {
      await _repository.deleteProduct(id);
      await loadProductsFromApi(useSampleFallback: false);
      if (removed != null) {
        _auditLog?.record(
          module: AuditLogViewModel.moduleInventory,
          category: AuditLogViewModel.categoryProductCatalog,
          summary: 'Product removed: ${removed.name} (${removed.itemCode})',
          detail: 'Category: ${removed.category}',
        );
      }
    } catch (e) {
      inventoryError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Receive stock: persists to API when online, else updates local demo state.
  Future<void> applySupplierDelivery({
    required String supplierName,
    String? supplierCode,
    required String warehouseLocation,
    required String invoiceNumber,
    required String receivedBy,
    required String notes,
    required List<SupplierDeliveryItem> items,
  }) async {
    final qtyById = <int, int>{};
    for (final item in items) {
      if (item.productId <= 0 || item.quantity <= 0) continue;
      qtyById[item.productId] = (qtyById[item.productId] ?? 0) + item.quantity;
    }
    if (qtyById.isEmpty) return;

    final supplierTrim = supplierName.trim();
    final locTrim = warehouseLocation.trim();

    String resolvedName = supplierTrim;
    String? resolvedCode = supplierCode?.trim().isEmpty == true
        ? null
        : supplierCode?.trim();
    if (supplierTrim.isNotEmpty) {
      final lower = supplierTrim.toLowerCase();
      Supplier? match;
      for (final s in Suppliers.all) {
        if (s.code.toLowerCase() == lower) {
          match = s;
          break;
        }
      }
      match ??= () {
        for (final s in Suppliers.all) {
          if (s.name.toLowerCase() == lower) return s;
        }
        return null;
      }();
      match ??= () {
        for (final s in Suppliers.all) {
          if (s.name.toLowerCase().contains(lower) ||
              lower.contains(s.name.toLowerCase())) {
            return s;
          }
        }
        return null;
      }();
      if (match != null) {
        resolvedCode ??= match.code;
        resolvedName = match.name;
      }
    }

    final totalUnits = qtyById.values.fold<int>(0, (a, b) => a + b);
    final lineSummaries = <String>[];
    for (final e in qtyById.entries) {
      final p = _productById(e.key);
      lineSummaries.add(
        '${p?.name ?? 'ID ${e.key}'}: +${e.value} ${p?.unit ?? 'units'}',
      );
    }

    if (_usingOfflineSample) {
      _products = _products.map((p) {
        final add = qtyById[p.id];
        if (add == null) return p;
        return p.copyWith(
          stock: p.stock + add,
          supplier: resolvedName.isNotEmpty ? resolvedName : p.supplier,
          supplierCode: resolvedCode ?? p.supplierCode,
          location: locTrim.isNotEmpty ? locTrim : p.location,
        );
      }).toList();

      _deliveryHistory.insert(
        0,
        InventoryDeliveryRecord(
          receivedAt: DateTime.now(),
          supplierName: resolvedName.isNotEmpty ? resolvedName : supplierTrim,
          warehouseLocation: locTrim,
          receivedBy: receivedBy.trim(),
          lineCount: qtyById.length,
          totalUnits: totalUnits,
        ),
      );
      _auditLog?.record(
        module: AuditLogViewModel.moduleInventory,
        category: AuditLogViewModel.categoryReceiving,
        summary:
            'Supplier delivery received · $totalUnits units across ${qtyById.length} line(s)'
            '${resolvedName.isNotEmpty ? ' · $resolvedName' : ''}',
        detail: [
          if (locTrim.isNotEmpty) 'Putaway: $locTrim',
          'Lines: ${lineSummaries.join('; ')}',
        ].join('\n'),
      );
      _applyFilters();
      return;
    }

    try {
      await _repository.receiveDelivery(
        supplierName: resolvedName.isNotEmpty ? resolvedName : supplierTrim,
        supplierCode: resolvedCode,
        warehouseLocation: locTrim,
        invoiceNumber: invoiceNumber,
        receivedBy: receivedBy,
        notes: notes,
        items: items,
      );
      await loadProductsFromApi(useSampleFallback: false);
      _auditLog?.record(
        module: AuditLogViewModel.moduleInventory,
        category: AuditLogViewModel.categoryReceiving,
        summary:
            'Supplier delivery received · $totalUnits units across ${qtyById.length} line(s)'
            '${resolvedName.isNotEmpty ? ' · $resolvedName' : ''}',
        detail: [
          if (locTrim.isNotEmpty) 'Putaway: $locTrim',
          'Lines: ${lineSummaries.join('; ')}',
        ].join('\n'),
      );
    } catch (e) {
      inventoryError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Product? _productById(int id) {
    for (final p in _products) {
      if (p.id == id) return p;
    }
    return null;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void setSelectedBrand(String brand) {
    _selectedBrand = brand;
    _applyFilters();
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    _applyFilters();
  }

  void setSelectedSupplier(String supplier) {
    _selectedSupplier = supplier;
    _applyFilters();
  }

  void toggleSidebar() {
    _sidebarOpen = !_sidebarOpen;
    notifyListeners();
  }

  void setActiveNav(String nav) {
    _activeNav = nav;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = '';
    _selectedBrand = '';
    _selectedStatus = '';
    _selectedSupplier = '';
    _searchQuery = '';
    _applyFilters();
  }

  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.brand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.itemCode.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory.isEmpty || product.category == _selectedCategory;
      final matchesBrand =
          _selectedBrand.isEmpty || product.brand == _selectedBrand;
      final matchesSupplier =
          _selectedSupplier.isEmpty ||
          product.supplierCode == _selectedSupplier;

      var matchesStatus = true;
      if (_selectedStatus.isNotEmpty) {
        if (_selectedStatus == 'OK' && product.stockStatus != StockStatus.ok) {
          matchesStatus = false;
        }
        if (_selectedStatus == 'LOW' &&
            product.stockStatus != StockStatus.low) {
          matchesStatus = false;
        }
        if (_selectedStatus == 'CRITICAL' &&
            product.stockStatus != StockStatus.critical) {
          matchesStatus = false;
        }
      }

      return matchesSearch &&
          matchesCategory &&
          matchesBrand &&
          matchesSupplier &&
          matchesStatus;
    }).toList();
    notifyListeners();
  }
}
