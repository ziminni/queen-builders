import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../routes/routes.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../widgets/inventory_page_layout.dart';
import '../viewmodels/inventory_viewmodel.dart';

class InventoryReportsPage extends StatefulWidget {
  const InventoryReportsPage({super.key});

  @override
  State<InventoryReportsPage> createState() => _InventoryReportsPageState();
}

class _InventoryReportsPageState extends State<InventoryReportsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final vm = context.read<InventoryViewModel>();
      await vm.loadProductsFromApi();
      if (!mounted) return;
      vm.setActiveNav('reports');
    });
  }

  Future<void> _logout() async {
    await context.read<AuthViewModel>().logout();
    if (mounted) context.go(AppRoutes.login);
  }

  void _stubExport(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label will connect to export once reporting is wired up.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InventoryPageLayout(
      headerTitle: 'Reports',
      onLogout: () => _logout(),
      body: Consumer<InventoryViewModel>(
        builder: (context, vm, _) {
          final inventoryValue = vm.products.fold<double>(
            0,
            (s, p) => s + p.costPrice * p.stock,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inventory reports',
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Snapshot metrics from your current stock file. Exports are placeholders until backend reporting exists.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ReportCard(
                        title: 'Stock valuation',
                        subtitle:
                            'Cost basis × on-hand qty: ₱${inventoryValue.toStringAsFixed(0)}',
                        icon: Icons.account_balance_wallet_outlined,
                        actions: [
                          _ReportAction(
                            label: 'Download CSV',
                            onTap: () => _stubExport(context, 'CSV'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ReportCard(
                        title: 'Movement summary',
                        subtitle:
                            '${vm.deliveryHistory.length} deliveries logged in this session',
                        icon: Icons.swap_vert_circle_outlined,
                        actions: [
                          _ReportAction(
                            label: 'PDF summary',
                            onTap: () => _stubExport(context, 'PDF'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ReportCard(
                        title: 'Reorder worksheet',
                        subtitle:
                            '${vm.lowAndCriticalCount} SKUs need attention',
                        icon: Icons.assignment_outlined,
                        actions: [
                          _ReportAction(
                            label: 'Export list',
                            onTap: () => _stubExport(context, 'Reorder list'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> actions;

  const _ReportCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.richGold, size: 28),
          const SizedBox(height: 14),
          Text(title, style: AppTextStyles.h4.copyWith(fontSize: 17)),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          ...actions,
        ],
      ),
    );
  }
}

class _ReportAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ReportAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.download_outlined, size: 18),
          label: Text(label),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.richGold,
          ),
        ),
      ),
    );
  }
}
