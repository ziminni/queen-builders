import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/product.dart';
import '../../../core/services/storage_service.dart';
import '../widgets/inventory_sidebar.dart';
import '../widgets/inventory_header.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  String activeNav = 'inventory';
  String selectedCategory = '';
  String selectedBrand = '';
  String selectedStatus = '';
  String selectedSupplier = '';
  String searchQuery = '';
  bool sidebarOpen = true; // Sidebar toggle state

  List<Product> products = [];
  List<Product> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    products = _getSampleProducts();
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      filteredProducts = products.where((product) {
        final matchesSearch = searchQuery.isEmpty ||
            product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            product.category.toLowerCase().contains(searchQuery.toLowerCase()) ||
            product.brand.toLowerCase().contains(searchQuery.toLowerCase()) ||
            product.itemCode.toLowerCase().contains(searchQuery.toLowerCase());

        final matchesCategory = selectedCategory.isEmpty || product.category == selectedCategory;
        final matchesBrand = selectedBrand.isEmpty || product.brand == selectedBrand;
        final matchesSupplier = selectedSupplier.isEmpty || product.supplierCode == selectedSupplier;

        bool matchesStatus = true;
        if (selectedStatus.isNotEmpty) {
          if (selectedStatus == 'OK' && product.stockStatus != StockStatus.ok) matchesStatus = false;
          if (selectedStatus == 'LOW' && product.stockStatus != StockStatus.low) matchesStatus = false;
          if (selectedStatus == 'CRITICAL' && product.stockStatus != StockStatus.critical) matchesStatus = false;
        }

        return matchesSearch && matchesCategory && matchesBrand && matchesSupplier && matchesStatus;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      selectedCategory = '';
      selectedBrand = '';
      selectedStatus = '';
      selectedSupplier = '';
      searchQuery = '';
      _applyFilters();
    });
  }

  Future<void> _handleLogout() async {
    final storageService = StorageService();
    await storageService.clearAll();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Row(
        children: [
          // Sidebar
          InventorySidebar(
            activeNav: activeNav,
            isOpen: sidebarOpen,
            onNavChange: (nav) {
              setState(() {
                activeNav = nav;
              });
            },
            onLogout: _handleLogout,
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                InventoryHeader(
                  title: 'Stock Manager Dashboard',
                  searchQuery: searchQuery,
                  onSearchChanged: (query) {
                    setState(() {
                      searchQuery = query;
                      _applyFilters();
                    });
                  },
                  onMenuToggle: () {
                    setState(() {
                      sidebarOpen = !sidebarOpen;
                    });
                  },
                  onNotificationTap: () {},
                  onProfileTap: () {},
                ),

                // Main Content Area with Page Title & Action Buttons
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Page Title & Action Buttons Section
                          _buildPageHeader(),

                          const SizedBox(height: 32),

                          // Filters Bar
                          _buildFiltersBar(),

                          const SizedBox(height: 24),

                          // Products Table
                          _buildProductsTable(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title and Subtitle - Make flexible
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inventory Management',
                style: AppTextStyles.h1.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'Manage products, stock levels, and supplier deliveries',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Action Buttons - Wrap for smaller screens
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // Receive Delivery Button
            OutlinedButton.icon(
              onPressed: () {
                // Handle receive delivery
              },
              icon: const Icon(Icons.local_shipping, size: 18),
              label: Text(
                'Receive Delivery',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.richGold,
                  fontSize: 13,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                side: const BorderSide(color: AppColors.richGold, width: 2),
                foregroundColor: AppColors.richGold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            // Adjust Stock Button
            OutlinedButton.icon(
              onPressed: () {
                // Handle adjust stock
              },
              icon: const Icon(Icons.edit, size: 18),
              label: Text(
                'Adjust Stock',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.richGold,
                  fontSize: 13,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                side: const BorderSide(color: AppColors.richGold, width: 2),
                foregroundColor: AppColors.richGold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            // Add Product Button
            ElevatedButton.icon(
              onPressed: () {
                // Handle add product
              },
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                'Add Product',
                style: AppTextStyles.button.copyWith(fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.richGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFiltersBar() {
    final categories = ['', 'Paint & Finishing', 'Cement', 'Aggregates', 'Steel', 'Wood',
      'Nails & Fasteners', 'Blocks', 'Roofing', 'Electrical', 'Plumbing', 'Tools', 'Safety Equipment'];
    final brands = ['', ...products.map((p) => p.brand).toSet().toList()..sort()];
    final statuses = ['', 'OK', 'LOW', 'CRITICAL'];
    final suppliers = ['', ...products.map((p) => p.supplierCode ?? '').where((s) => s.isNotEmpty).toSet().toList()..sort()];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  label: 'Filter by Category',
                  value: selectedCategory,
                  items: categories,
                  displayText: (val) => val.isEmpty ? 'All Categories' : val,
                  onChanged: (val) {
                    setState(() {
                      selectedCategory = val ?? '';
                      _applyFilters();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterDropdown(
                  label: 'Filter by Brand',
                  value: selectedBrand,
                  items: brands,
                  displayText: (val) => val.isEmpty ? 'All Brands' : val,
                  onChanged: (val) {
                    setState(() {
                      selectedBrand = val ?? '';
                      _applyFilters();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterDropdown(
                  label: 'Filter by Status',
                  value: selectedStatus,
                  items: statuses,
                  displayText: (val) => val.isEmpty ? 'All Status' : val,
                  onChanged: (val) {
                    setState(() {
                      selectedStatus = val ?? '';
                      _applyFilters();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterDropdown(
                  label: 'Filter by Supplier',
                  value: selectedSupplier,
                  items: suppliers,
                  displayText: (val) => val.isEmpty ? 'All Suppliers' : val,
                  onChanged: (val) {
                    setState(() {
                      selectedSupplier = val ?? '';
                      _applyFilters();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: _clearFilters,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  side: const BorderSide(color: AppColors.border, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Clear Filters',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required String Function(String) displayText,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 2),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  displayText(item),
                  style: AppTextStyles.bodySmall,
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildProductsTable() {
    return Container(
      height: 600,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                _buildTableHeaderCell('Category', flex: 2),
                _buildTableHeaderCell('Brand', flex: 2),
                _buildTableHeaderCell('SKU', flex: 2),
                _buildTableHeaderCell('Description', flex: 3),
                _buildTableHeaderCell('Stock', flex: 1, alignment: TextAlign.center),
                _buildTableHeaderCell('Cost (₱)', flex: 2, alignment: TextAlign.right),
                _buildTableHeaderCell('Markup %', flex: 1, alignment: TextAlign.center),
                _buildTableHeaderCell('Selling (₱)', flex: 2, alignment: TextAlign.right),
                _buildTableHeaderCell('Supplier', flex: 2),
                _buildTableHeaderCell('Location', flex: 2),
                _buildTableHeaderCell('Status', flex: 2, alignment: TextAlign.center),
                _buildTableHeaderCell('Actions', flex: 2, alignment: TextAlign.center),
              ],
            ),
          ),

          // Table Body
          Expanded(
            child: filteredProducts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return _buildTableRow(filteredProducts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String text, {int flex = 1, TextAlign alignment = TextAlign.left}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
        textAlign: alignment,
      ),
    );
  }

  Widget _buildTableRow(Product product) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border),
          ),
        ),
        child: Row(
          children: [
            // Category
            Expanded(
              flex: 2,
              child: Text(
                product.category,
                style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
              ),
            ),
            // Brand
            Expanded(
              flex: 2,
              child: Text(
                product.brand,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            // SKU
            Expanded(
              flex: 2,
              child: Text(
                product.itemCode,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.richGold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            // Description
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    product.specifications,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Stock
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Text(
                    '${product.stock}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    product.unit,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Cost
            Expanded(
              flex: 2,
              child: Text(
                '₱${product.costPrice.toStringAsFixed(2)}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            // Markup
            Expanded(
              flex: 1,
              child: Text(
                '${product.markupPercent.toStringAsFixed(0)}%',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.richGold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Selling Price
            Expanded(
              flex: 2,
              child: Text(
                '₱${product.sellingPrice.toStringAsFixed(2)}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            // Supplier
            Expanded(
              flex: 2,
              child: Text(
                product.supplierCode ?? '-',
                style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
              ),
            ),
            // Location
            Expanded(
              flex: 2,
              child: Text(
                product.location ?? '-',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            // Status
            Expanded(
              flex: 2,
              child: Center(
                child: _buildStatusBadge(product.stockStatus),
              ),
            ),
            // Actions
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 16),
                    color: AppColors.richGold,
                    onPressed: () {},
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 16),
                    color: AppColors.textSecondary,
                    onPressed: () {},
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(StockStatus status) {
    Color bgColor, textColor;
    String label;

    switch (status) {
      case StockStatus.ok:
        bgColor = AppColors.stockOk.withOpacity(0.1);
        textColor = AppColors.stockOk;
        label = 'OK';
        break;
      case StockStatus.low:
        bgColor = AppColors.stockLow.withOpacity(0.1);
        textColor = AppColors.stockLow;
        label = 'LOW';
        break;
      case StockStatus.critical:
        bgColor = AppColors.stockCritical.withOpacity(0.1);
        textColor = AppColors.stockCritical;
        label = 'CRITICAL';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List<Product> _getSampleProducts() {
    return [
      Product(
        id: 1,
        itemCode: 'PNT001-BOY-WHT-1L',
        name: 'Boysen Premium White 1L',
        description: 'Premium quality latex white paint, 1 liter',
        category: 'Paint & Finishing',
        subcategory: 'Interior Paint',
        brand: 'Boysen',
        specifications: '1L, White, Latex',
        unit: 'liter',
        costPrice: 150,
        markupPercent: 30,
        sellingPrice: 195,
        stock: 80,
        reorderLevel: 20,
        reorderQuantity: 50,
        supplier: 'Supplier A - Boysen Paint Center',
        supplierCode: 'SUP-A',
        location: 'Aisle 1-A',
        taxable: true,
      ),
      Product(
        id: 2,
        itemCode: 'PNT001-BOY-WHT-4L',
        name: 'Boysen Premium White 4L',
        description: 'Premium quality latex white paint, 4 liters',
        category: 'Paint & Finishing',
        subcategory: 'Interior Paint',
        brand: 'Boysen',
        specifications: '4L, White, Latex',
        unit: 'gallon',
        costPrice: 560,
        markupPercent: 30,
        sellingPrice: 728,
        stock: 45,
        reorderLevel: 15,
        reorderQuantity: 30,
        supplier: 'Supplier A - Boysen Paint Center',
        supplierCode: 'SUP-A',
        location: 'Aisle 1-A',
        taxable: true,
      ),
      Product(
        id: 12,
        itemCode: 'CMT001-HOL-PTL-40KG',
        name: 'Holcim Portland Cement 40kg',
        description: 'Type 1 Portland cement, 40kg bag',
        category: 'Cement',
        subcategory: 'Portland Cement',
        brand: 'Holcim',
        specifications: '40kg, Type 1',
        unit: 'bag',
        costPrice: 220,
        markupPercent: 20,
        sellingPrice: 264,
        stock: 450,
        reorderLevel: 100,
        reorderQuantity: 200,
        supplier: 'Supplier C - Holcim Philippines',
        supplierCode: 'SUP-C',
        location: 'Warehouse Zone A',
        taxable: true,
      ),
      Product(
        id: 17,
        itemCode: 'STL001-PAG-RBR-10MM',
        name: 'Pag-asa Steel 10mm Rebar',
        description: 'Deformed steel rebar, 10mm diameter, 6 meters',
        category: 'Steel',
        subcategory: 'Rebar',
        brand: 'Pag-asa Steel',
        specifications: '10mm x 6m, Grade 40',
        unit: 'piece',
        costPrice: 250,
        markupPercent: 20,
        sellingPrice: 300,
        stock: 15,
        reorderLevel: 200,
        reorderQuantity: 500,
        supplier: 'Supplier G - Pag-asa Steel Corp',
        supplierCode: 'SUP-G',
        location: 'Warehouse Zone B',
        taxable: true,
      ),
      Product(
        id: 21,
        itemCode: 'WOD001-LCL-2X2-8FT',
        name: 'Local Timber 2x2 Lumber (8ft)',
        description: 'Kiln-dried lumber, 2x2 inches, 8 feet',
        category: 'Wood',
        subcategory: 'Lumber',
        brand: 'Local Timber',
        specifications: '2x2" x 8ft, Kiln-dried',
        unit: 'piece',
        costPrice: 120,
        markupPercent: 35,
        sellingPrice: 162,
        stock: 500,
        reorderLevel: 80,
        reorderQuantity: 200,
        supplier: 'Supplier F - Local Timber Supply',
        supplierCode: 'SUP-F',
        location: 'Warehouse Zone C',
        taxable: true,
      ),
    ];
  }
}
