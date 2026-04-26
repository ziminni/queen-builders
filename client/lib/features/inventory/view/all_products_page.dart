import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/product.dart';
import '../../../routes/routes.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodels/inventory_viewmodel.dart';
import '../models/sample_products.dart';
import '../widgets/inventory_sidebar.dart';
import '../widgets/inventory_header.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryViewModel>().initializeProducts(getSampleInventoryProducts());
    });
  }

  Future<void> _handleLogout() async {
    await context.read<AuthViewModel>().logout();
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          body: Row(
            children: [
              // Sidebar
              InventorySidebar(
                activeNav: viewModel.activeNav,
                isOpen: viewModel.sidebarOpen,
                onNavChange: (nav) {
                  viewModel.setActiveNav(nav);
                  if (nav == 'dashboard') {
                    context.go(AppRoutes.stockManager);
                  } else if (nav == 'inventory') {
                    // Already in all products page
                  }
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
                      searchQuery: viewModel.searchQuery,
                      onSearchChanged: (query) {
                        viewModel.setSearchQuery(query);
                      },
                      onMenuToggle: () {
                        viewModel.toggleSidebar();
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
                              _buildFiltersBar(viewModel),

                              const SizedBox(height: 24),

                              // Products Table
                              _buildProductsTable(viewModel),
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
      },
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

  Widget _buildFiltersBar(InventoryViewModel viewModel) {
    final categories = ['', 'Paint & Finishing', 'Cement', 'Aggregates', 'Steel', 'Wood',
      'Nails & Fasteners', 'Blocks', 'Roofing', 'Electrical', 'Plumbing', 'Tools', 'Safety Equipment'];
    final brands = ['', ...viewModel.products.map((p) => p.brand).toSet().toList()..sort()];
    final statuses = ['', 'OK', 'LOW', 'CRITICAL'];
    final suppliers = ['', ...viewModel.products.map((p) => p.supplierCode ?? '').where((s) => s.isNotEmpty).toSet().toList()..sort()];

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
                  value: viewModel.selectedCategory,
                  items: categories,
                  displayText: (val) => val.isEmpty ? 'All Categories' : val,
                  onChanged: (val) {
                    viewModel.setSelectedCategory(val ?? '');
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterDropdown(
                  label: 'Filter by Brand',
                  value: viewModel.selectedBrand,
                  items: brands,
                  displayText: (val) => val.isEmpty ? 'All Brands' : val,
                  onChanged: (val) {
                    viewModel.setSelectedBrand(val ?? '');
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterDropdown(
                  label: 'Filter by Status',
                  value: viewModel.selectedStatus,
                  items: statuses,
                  displayText: (val) => val.isEmpty ? 'All Status' : val,
                  onChanged: (val) {
                    viewModel.setSelectedStatus(val ?? '');
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterDropdown(
                  label: 'Filter by Supplier',
                  value: viewModel.selectedSupplier,
                  items: suppliers,
                  displayText: (val) => val.isEmpty ? 'All Suppliers' : val,
                  onChanged: (val) {
                    viewModel.setSelectedSupplier(val ?? '');
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
                onPressed: () => viewModel.clearFilters(),
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

  Widget _buildProductsTable(InventoryViewModel viewModel) {
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
            child: viewModel.filteredProducts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: viewModel.filteredProducts.length,
                    itemBuilder: (context, index) {
                      return _buildTableRow(viewModel.filteredProducts[index]);
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
}
