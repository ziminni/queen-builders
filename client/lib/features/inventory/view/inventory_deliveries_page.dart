import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../routes/routes.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../widgets/inventory_page_layout.dart';
import '../viewmodels/inventory_viewmodel.dart';

class InventoryDeliveriesPage extends StatefulWidget {
  const InventoryDeliveriesPage({super.key});

  @override
  State<InventoryDeliveriesPage> createState() => _InventoryDeliveriesPageState();
}

class _InventoryDeliveriesPageState extends State<InventoryDeliveriesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final vm = context.read<InventoryViewModel>();
      await vm.loadProductsFromApi();
      if (!mounted) return;
      vm.setActiveNav('deliveries');
    });
  }

  Future<void> _logout() async {
    await context.read<AuthViewModel>().logout();
    if (mounted) context.go(AppRoutes.login);
  }

  static String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return InventoryPageLayout(
      headerTitle: 'Deliveries',
      onLogout: () => _logout(),
      body: Consumer<InventoryViewModel>(
        builder: (context, vm, _) {
          final history = vm.deliveryHistory;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inbound receipts',
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Logged when you confirm a supplier delivery. Newest first.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                if (history.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            size: 52,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No deliveries recorded yet',
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Use Receive delivery from the dashboard or alerts page.',
                            style: AppTextStyles.bodySmall.copyWith(
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(9),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Expanded(flex: 2, child: _H('Received')),
                              Expanded(flex: 2, child: _H('Supplier')),
                              Expanded(flex: 2, child: _H('Received by')),
                              Expanded(flex: 2, child: _H('Location')),
                              Expanded(flex: 1, child: _H('Lines', right: true)),
                              Expanded(flex: 1, child: _H('Units', right: true)),
                            ],
                          ),
                        ),
                        for (var i = 0; i < history.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _fmtDate(history[i].receivedAt),
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    history[i].supplierName.isEmpty
                                        ? '—'
                                        : history[i].supplierName,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    history[i].receivedBy.isEmpty
                                        ? '—'
                                        : history[i].receivedBy,
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    history[i].warehouseLocation.isEmpty
                                        ? '—'
                                        : history[i].warehouseLocation,
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '${history[i].lineCount}',
                                    textAlign: TextAlign.right,
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '${history[i].totalUnits}',
                                    textAlign: TextAlign.right,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.richGold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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

class _H extends StatelessWidget {
  final String text;
  final bool right;

  const _H(this.text, {this.right = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: right ? TextAlign.right : TextAlign.left,
      style: AppTextStyles.labelSmall.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 10,
      ),
    );
  }
}
