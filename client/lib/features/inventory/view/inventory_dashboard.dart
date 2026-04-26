import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../routes/routes.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../widgets/inventory_header.dart';
import '../widgets/inventory_sidebar.dart';
import '../viewmodels/inventory_viewmodel.dart';

class InventoryDashboard extends StatelessWidget {
  const InventoryDashboard({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    await context.read<AuthViewModel>().logout();
    if (context.mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topProducts = [
      ('Boysen Premium White 1L', 124),
      ('Holcim Portland Cement 40kg', 98),
      ('Pag-asa Steel 10mm Rebar', 76),
      ('Local Timber 2x2 Lumber (8ft)', 62),
    ];
    final monthlyMovement = [48, 52, 44, 60, 55, 68];

    return Consumer<InventoryViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          body: Row(
            children: [
              InventorySidebar(
                activeNav: viewModel.activeNav,
                isOpen: viewModel.sidebarOpen,
                onNavChange: (nav) {
                  viewModel.setActiveNav(nav);
                  if (nav == 'inventory') {
                    context.go(AppRoutes.stockManagerProducts);
                  }
                },
                onLogout: () => _handleLogout(context),
              ),
              Expanded(
                child: Column(
                  children: [
                    InventoryHeader(
                      title: 'Inventory Dashboard',
                      searchQuery: viewModel.searchQuery,
                      onSearchChanged: (value) => viewModel.setSearchQuery(value),
                      onMenuToggle: () => viewModel.toggleSidebar(),
                      onNotificationTap: () {},
                      onProfileTap: () {},
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Inventory Dashboard',
                              style: AppTextStyles.h1.copyWith(
                                fontSize: 34,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Essential stock insights and quick actions.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                _quickActionButton(
                                  icon: Icons.inventory_2_outlined,
                                  label: 'All Products',
                                  onTap: () => context.go(AppRoutes.stockManagerProducts),
                                ),
                                const SizedBox(width: 12),
                                _quickActionButton(
                                  icon: Icons.add_circle_outline,
                                  label: 'Add Product',
                                  onTap: () {},
                                ),
                                const SizedBox(width: 12),
                                _quickActionButton(
                                  icon: Icons.local_shipping_outlined,
                                  label: 'Receive Delivery',
                                  onTap: () {},
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: const [
                                _StatCard(
                                  label: 'Total Products',
                                  value: '44',
                                  icon: Icons.inventory_2_outlined,
                                  color: AppColors.richGold,
                                ),
                                SizedBox(width: 16),
                                _StatCard(
                                  label: 'Low Stock Items',
                                  value: '9',
                                  icon: Icons.warning_amber_outlined,
                                  color: AppColors.stockLow,
                                ),
                                SizedBox(width: 16),
                                _StatCard(
                                  label: 'Total Units',
                                  value: '15,885',
                                  icon: Icons.local_shipping_outlined,
                                  color: AppColors.richGold,
                                ),
                                SizedBox(width: 16),
                                _StatCard(
                                  label: 'Pending Requests',
                                  value: '0',
                                  icon: Icons.notifications_none_outlined,
                                  color: AppColors.stockCritical,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _panel(
                                    title: 'Stock Status Distribution',
                                    child: Column(
                                      children: const [
                                        _ProgressMetric(label: 'Healthy', percent: 0.73, color: AppColors.stockOk),
                                        SizedBox(height: 12),
                                        _ProgressMetric(label: 'Low', percent: 0.20, color: AppColors.stockLow),
                                        SizedBox(height: 12),
                                        _ProgressMetric(label: 'Critical', percent: 0.07, color: AppColors.stockCritical),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _panel(
                                    title: 'Monthly Stock Movement',
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        for (final value in monthlyMovement)
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 4),
                                              child: Container(
                                                height: value.toDouble() * 1.5,
                                                decoration: BoxDecoration(
                                                  color: AppColors.richGold.withOpacity(0.7),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _panel(
                              title: 'Top Moving Products',
                              child: Column(
                                children: [
                                  for (final item in topProducts) ...[
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.$1,
                                            style: AppTextStyles.bodyMedium.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${item.$2} units',
                                          style: AppTextStyles.labelMedium.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (item != topProducts.last) const Divider(height: 20),
                                  ],
                                ],
                              ),
                            ),
                          ],
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

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: AppTextStyles.button.copyWith(
          color: AppColors.richGold,
          fontSize: 13,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.richGold, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _panel({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h4.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 24,
                      color: color == AppColors.stockCritical ? AppColors.stockCritical : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;

  const _ProgressMetric({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final safePercent = percent.clamp(0, 1).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.labelMedium),
            const Spacer(),
            Text('${(safePercent * 100).toStringAsFixed(0)}%', style: AppTextStyles.labelMedium),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: safePercent,
            minHeight: 8,
            backgroundColor: AppColors.border.withOpacity(0.6),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}