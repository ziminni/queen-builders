import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/product.dart';
import '../../../routes/routes.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../widgets/inventory_page_layout.dart';
import '../widgets/receive_supplier_delivery_dialog.dart';
import '../viewmodels/inventory_viewmodel.dart';

class InventoryAlertsPage extends StatefulWidget {
  const InventoryAlertsPage({super.key});

  @override
  State<InventoryAlertsPage> createState() => _InventoryAlertsPageState();
}

class _InventoryAlertsPageState extends State<InventoryAlertsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final vm = context.read<InventoryViewModel>();
      await vm.loadProductsFromApi();
      if (!mounted) return;
      vm.setActiveNav('alerts');
    });
  }

  Future<void> _logout() async {
    await context.read<AuthViewModel>().logout();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return InventoryPageLayout(
      headerTitle: 'Low stock alerts',
      onLogout: () => _logout(),
      body: Consumer<InventoryViewModel>(
        builder: (context, vm, _) {
          final alerts = vm.products
              .where((p) => p.stockStatus != StockStatus.ok)
              .toList()
            ..sort((a, b) => a.stock.compareTo(b.stock));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reorder attention list',
                            style: AppTextStyles.h1.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Items at or below reorder level. Receive stock or adjust reorder points on the products page.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (dialogContext) =>
                              ReceiveSupplierDeliveryDialog(
                            products: vm.products,
                            onConfirm: (supplier, supplierCode, invoice, date,
                                receivedBy, notes, wh, items) async {
                              try {
                                await vm.applySupplierDelivery(
                                  supplierName: supplier,
                                  supplierCode: supplierCode,
                                  warehouseLocation: wh,
                                  invoiceNumber: invoice,
                                  receivedBy: receivedBy,
                                  notes: notes,
                                  items: items,
                                );
                              } catch (_) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Could not record delivery. Check the server.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.local_shipping_outlined, size: 18),
                      label: const Text('Receive delivery'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.richGold,
                        side: const BorderSide(color: AppColors.richGold, width: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                if (alerts.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 56,
                            color: AppColors.stockOk.withOpacity(0.7),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No low or critical items right now',
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < alerts.length; i++) ...[
                          if (i > 0)
                            const Divider(height: 1),
                          _AlertRow(product: alerts[i]),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final Product product;

  const _AlertRow({required this.product});

  @override
  Widget build(BuildContext context) {
    final st = product.stockStatus;
    final color = st == StockStatus.critical
        ? AppColors.stockCritical
        : AppColors.stockLow;
    final label = st == StockStatus.critical ? 'Critical' : 'Low';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.itemCode} · ${product.category}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${product.stock} ${product.unit} on hand',
              style: AppTextStyles.bodySmall,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Reorder at ${product.reorderLevel} · target ${product.reorderQuantity}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
