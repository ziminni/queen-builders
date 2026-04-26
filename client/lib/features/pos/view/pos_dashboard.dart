import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../routes/routes.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodels/pos_viewmodel.dart';
import '../models/sample_products.dart';
import '../widgets/pos_header.dart';
import '../widgets/product_card.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/checkout_section.dart';
import '../widgets/profile_overlay.dart';

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
      context.read<POSViewModel>().setProducts(getSamplePOSProducts());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<POSViewModel>(
      builder: (context, viewModel, _) {
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
                    _buildSearchBar(viewModel),

                    // Product Grid
                    Expanded(
                      child: _buildProductGrid(viewModel),
                    ),
                  ],
                ),
              ),

              // Right Sidebar - Shopping Cart
              _buildCartSidebar(viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(POSViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: TextField(
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
      ),
    );
  }

  Widget _buildProductGrid(POSViewModel viewModel) {
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
  }

  Widget _buildCartSidebar(POSViewModel viewModel) {
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
    ProfileOverlay.show(
      context,
      userName: 'Maria Santos',
      userRole: 'Store Cashier',
      userInitials: 'MS',
      onLogout: _handleLogout,
    );
  }

  Future<void> _handleLogout() async {
    await context.read<AuthViewModel>().logout();
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }
}
