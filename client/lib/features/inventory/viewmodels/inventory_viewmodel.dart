import 'package:flutter/foundation.dart';
import '../../../data/models/product.dart';

class InventoryViewModel extends ChangeNotifier {
  // State variables
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = '';
  String _selectedCategory = '';
  String _selectedBrand = '';
  String _selectedStatus = '';
  String _selectedSupplier = '';
  bool _sidebarOpen = true;
  String _activeNav = 'dashboard';

  // Getters
  List<Product> get products => _products;
  List<Product> get filteredProducts => _filteredProducts;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedBrand => _selectedBrand;
  String get selectedStatus => _selectedStatus;
  String get selectedSupplier => _selectedSupplier;
  bool get sidebarOpen => _sidebarOpen;
  String get activeNav => _activeNav;

  // Initialize with products
  void initializeProducts(List<Product> products) {
    _products = products;
    _applyFilters();
  }

  // Update search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // Update category filter
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  // Update brand filter
  void setSelectedBrand(String brand) {
    _selectedBrand = brand;
    _applyFilters();
  }

  // Update status filter
  void setSelectedStatus(String status) {
    _selectedStatus = status;
    _applyFilters();
  }

  // Update supplier filter
  void setSelectedSupplier(String supplier) {
    _selectedSupplier = supplier;
    _applyFilters();
  }

  // Toggle sidebar
  void toggleSidebar() {
    _sidebarOpen = !_sidebarOpen;
    notifyListeners();
  }

  // Set active navigation
  void setActiveNav(String nav) {
    _activeNav = nav;
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _selectedCategory = '';
    _selectedBrand = '';
    _selectedStatus = '';
    _selectedSupplier = '';
    _searchQuery = '';
    _applyFilters();
  }

  // Apply all filters
  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.brand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.itemCode.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory.isEmpty || product.category == _selectedCategory;
      final matchesBrand = _selectedBrand.isEmpty || product.brand == _selectedBrand;
      final matchesSupplier =
          _selectedSupplier.isEmpty || product.supplierCode == _selectedSupplier;

      bool matchesStatus = true;
      if (_selectedStatus.isNotEmpty) {
        if (_selectedStatus == 'OK' && product.stockStatus != StockStatus.ok)
          matchesStatus = false;
        if (_selectedStatus == 'LOW' && product.stockStatus != StockStatus.low)
          matchesStatus = false;
        if (_selectedStatus == 'CRITICAL' &&
            product.stockStatus != StockStatus.critical) matchesStatus = false;
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
