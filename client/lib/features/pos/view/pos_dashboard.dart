import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/product.dart';
import '../viewmodels/pos_viewmodel.dart';
import '../widgets/pos_header.dart';
import '../widgets/product_card.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/checkout_section.dart';

class POSDashboard extends StatefulWidget {
  const POSDashboard({super.key});

  @override
  State<POSDashboard> createState() => _POSDashboardState();
}

class _POSDashboardState extends State<POSDashboard> {
  @override
  void initState() {
    super.initState();
    // Load sample products
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<POSViewModel>().setProducts(_getSampleProducts());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Row(
        children: [
          // Main Content - Product Selection
          Expanded(
            child: Column(
              children: [
                // Header
                POSHeader(
                  onNotificationTap: () {},
                  onProfileTap: () => _showProfileMenu(context),
                  notificationCount: 0,
                ),

                // Search Bar
                _buildSearchBar(),

                // Product Grid
                Expanded(
                  child: _buildProductGrid(),
                ),
              ],
            ),
          ),

          // Right Sidebar - Shopping Cart
          _buildCartSidebar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Consumer<POSViewModel>(
        builder: (context, viewModel, _) {
          return TextField(
            onChanged: (value) => viewModel.setSearchQuery(value),
            decoration: InputDecoration(
              hintText: 'Search products by name or category...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
                size: 20,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.richGold, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: AppTextStyles.bodyMedium,
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return Consumer<POSViewModel>(
      builder: (context, viewModel, _) {
        final products = viewModel.filteredProducts;

        if (products.isEmpty) {
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
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.0,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ProductCard(
              product: products[index],
              onTap: () => viewModel.addToCart(products[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildCartSidebar() {
    return Consumer<POSViewModel>(
      builder: (context, viewModel, _) {
        return Container(
          width: 384,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(color: AppColors.border),
            ),
          ),
          child: Column(
            children: [
              // Cart Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.border),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.shopping_cart,
                          color: AppColors.richGold,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Current Sale',
                          style: AppTextStyles.h3.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (viewModel.cart.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            color: AppColors.textSecondary,
                            onPressed: () => _showClearCartDialog(viewModel),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${viewModel.cart.length} ${viewModel.cart.length == 1 ? 'item' : 'items'}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Cart Items
              Expanded(
                child: viewModel.cart.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: AppColors.textSecondary.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Cart is empty',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add items to get started',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: viewModel.cart.length,
                        itemBuilder: (context, index) {
                          final item = viewModel.cart[index];
                          return CartItemWidget(
                            item: item,
                            onIncrement: () => viewModel.updateQuantity(item.productId, 1),
                            onDecrement: () => viewModel.updateQuantity(item.productId, -1),
                            onRemove: () => viewModel.removeFromCart(item.productId),
                          );
                        },
                      ),
              ),

              // Checkout Section
              CheckoutSection(
                subtotal: viewModel.subtotal,
                tax: viewModel.tax,
                total: viewModel.total,
                hasItems: viewModel.cart.isNotEmpty,
                onCreditPayment: () => _processPayment(viewModel, 'Credit Card'),
                onCashPayment: () => _processPayment(viewModel, 'Cash'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processPayment(POSViewModel viewModel, String method) async {
    await viewModel.processPayment(method);
    if (mounted) {
      _showReceiptDialog();
    }
  }

  void _showClearCartDialog(POSViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Cart?', style: AppTextStyles.h3),
        content: Text(
          'Are you sure you want to clear all items from the cart?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.button.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.clearCart();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Clear', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  void _showReceiptDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.richGold, width: 2),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.richGold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt,
                color: AppColors.richGold,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Payment Successful!',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.deepBlack,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Receipt is being printed...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  void _showProfileMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.richGold, width: 2),
        ),
        title: Text(
          'Profile Information',
          style: AppTextStyles.h3.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.richGold,
                child: Text(
                  'MS',
                  style: AppTextStyles.h2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 32,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Maria Santos',
                style: AppTextStyles.h4.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Store Cashier',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildProfileInfoCard('Employee ID', 'EMP-2024-0156'),
              const SizedBox(height: 12),
              _buildProfileInfoCard('Department', 'Retail Operations'),
              const SizedBox(height: 12),
              _buildProfileInfoCard('Current Shift', '8:00 AM - 5:00 PM', Icons.access_time),
              const SizedBox(height: 12),
              _buildProfileInfoCard('Email', 'maria.santos@queenbuilders.com'),
              const SizedBox(height: 12),
              _buildProfileInfoCard('Contact', '+63 917 123 4567'),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.richGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Close', style: AppTextStyles.button.copyWith(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoCard(String label, String value, [IconData? icon]) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.richGold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.richGold),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.deepBlack,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
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
      // Add out of stock example
      Product(
        id: 99,
        itemCode: 'TST-OUT-STOCK',
        name: 'Out of Stock Item',
        description: 'Test item with no stock',
        category: 'Tools',
        subcategory: 'Hand Tools',
        brand: 'Test Brand',
        specifications: 'N/A',
        unit: 'piece',
        costPrice: 100,
        markupPercent: 25,
        sellingPrice: 125,
        stock: 0,
        reorderLevel: 10,
        reorderQuantity: 20,
        supplier: 'Test Supplier',
        supplierCode: 'TEST',
        location: 'Test',
        taxable: true,
      ),
    ];
  }
}
