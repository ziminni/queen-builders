import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../routes/routes.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodels/pos_viewmodel.dart';
import '../models/cart_item.dart';
import '../widgets/pos_header.dart';
import '../widgets/product_card.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/checkout_flow_dialogs.dart';
import '../widgets/pos_checkout_feedback.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final pos = context.read<POSViewModel>();
      await pos.loadPosCatalog();
      await pos.loadSalesHistory();
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
                      onProfileTap: () => _showProfileMenu(context, viewModel),
                      notificationCount: 0,
                    ),

                    // Search Bar
                    _buildSearchBar(viewModel),
                    if (viewModel.catalogError != null &&
                        viewModel.products.isEmpty &&
                        !viewModel.catalogLoading)
                      _buildCatalogErrorBanner(viewModel),
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

  Widget _buildCatalogErrorBanner(POSViewModel viewModel) {
    return Material(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.cloud_off_outlined, color: Colors.orange.shade800, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Using offline sample catalog. ${viewModel.catalogError ?? ""}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.orange.shade900,
                  fontSize: 12,
                ),
              ),
            ),
            TextButton(
              onPressed: viewModel.catalogLoading
                  ? null
                  : () {
                      viewModel.loadPosCatalog();
                    },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(POSViewModel viewModel) {
    final categories = viewModel.productCategories;
    final selected = viewModel.categoryFilter;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
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
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _categoryFilterChip(
                  viewModel: viewModel,
                  label: 'All',
                  category: null,
                  selected: selected == null,
                ),
                ...categories.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _categoryFilterChip(
                      viewModel: viewModel,
                      label: c,
                      category: c,
                      selected: selected == c,
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

  Widget _categoryFilterChip({
    required POSViewModel viewModel,
    required String label,
    required String? category,
    required bool selected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => viewModel.setCategoryFilter(category),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.richGold.withValues(alpha: 0.14)
                : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.richGold : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? AppColors.deepBlack : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(POSViewModel viewModel) {
    if (viewModel.catalogLoading && viewModel.products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.richGold),
      );
    }

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final pad = 24.0 * 2;
        final usableW = (constraints.maxWidth - pad).clamp(1.0, double.infinity);
        final maxExtent =
            usableW < 520 ? usableW / 2 - 12 : (usableW < 900 ? 220.0 : 260.0);

        return GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxExtent,
            childAspectRatio: 1.28,
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
            onPayLaterPayment: () => _onPayLaterPayment(viewModel),
            onCashPayment: () => _onCashPayment(viewModel),
          ),
        ],
      ),
    );
  }

  Future<void> _onCashPayment(POSViewModel viewModel) async {
    await showCashCustomerDialog(
      context,
      cartItems: List<CartItem>.from(viewModel.cart),
      subtotal: viewModel.subtotal,
      tax: viewModel.tax,
      total: viewModel.total,
      onConfirm: ({
        required isPayLater,
        required customerName,
        required contactNumber,
        String? customerAddress,
      }) async {
        await showPOSCheckoutFeedback(
          context,
          isPayLater: isPayLater,
          run: () async {
            if (isPayLater) {
              await viewModel.completePayLaterSale(
                customerName: customerName,
                customerAddress: customerAddress ?? '',
                contactNumber: contactNumber,
              );
            } else {
              await viewModel.completeCashSale(
                customerName: customerName,
                customerPhone: contactNumber,
              );
            }
          },
        );
      },
    );
  }

  Future<void> _onPayLaterPayment(POSViewModel viewModel) async {
    await showPayLaterCustomerDialog(
      context,
      orderTotal: viewModel.total,
      lineCount: viewModel.cart.length,
      onConfirm: ({required name, required address, required contact}) async {
        await showPOSCheckoutFeedback(
          context,
          isPayLater: true,
          run: () => viewModel.completePayLaterSale(
                customerName: name,
                customerAddress: address,
                contactNumber: contact,
              ),
        );
      },
    );
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

  void _showProfileMenu(BuildContext context, POSViewModel viewModel) {
    ProfileOverlay.show(
      context,
      userName: 'Maria Santos',
      userRole: 'Store Cashier',
      userInitials: 'MS',
      transactions: viewModel.transactions,
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
