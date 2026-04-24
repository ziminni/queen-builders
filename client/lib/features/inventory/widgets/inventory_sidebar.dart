import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class InventorySidebar extends StatelessWidget {
  final String activeNav;
  final bool isOpen;
  final Function(String) onNavChange;
  final VoidCallback? onLogout;

  const InventorySidebar({
    super.key,
    required this.activeNav,
    required this.isOpen,
    required this.onNavChange,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isOpen ? 260 : 80,
      decoration: BoxDecoration(
        color: AppColors.deepBlack,
        border: Border(
          right: BorderSide(color: AppColors.border.withOpacity(0.2)),
        ),
      ),
      child: Column(
        children: [
          // Logo/Brand Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.richGold.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: isOpen
                ? Row(
                    children: [
                      // QB Logo Circle
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.richGold,
                              AppColors.richGold.withOpacity(0.7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.richGold.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'QB',
                            style: AppTextStyles.h4.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Brand Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Queen Builders',
                              style: AppTextStyles.h4.copyWith(
                                color: AppColors.softWhite,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'STOCK MANAGER',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.richGold,
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.richGold,
                            AppColors.richGold.withOpacity(0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.richGold.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'QB',
                          style: AppTextStyles.h4.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              children: [
                _buildNavItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  navId: 'dashboard',
                ),
                _buildNavItem(
                  icon: Icons.inventory_2,
                  label: 'All Products',
                  navId: 'inventory',
                ),
                _buildNavItem(
                  icon: Icons.category,
                  label: 'Categories',
                  navId: 'categories',
                ),
                _buildNavItem(
                  icon: Icons.people,
                  label: 'Suppliers',
                  navId: 'suppliers',
                ),
                _buildNavItem(
                  icon: Icons.warning_amber,
                  label: 'Low Stock Alerts',
                  navId: 'alerts',
                ),
                _buildNavItem(
                  icon: Icons.local_shipping,
                  label: 'Deliveries',
                  navId: 'deliveries',
                ),
                _buildNavItem(
                  icon: Icons.description,
                  label: 'Reports',
                  navId: 'reports',
                ),
                _buildNavItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  navId: 'settings',
                ),
              ],
            ),
          ),

          // Logout Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.richGold.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Tooltip(
              message: isOpen ? '' : 'Logout',
              child: InkWell(
                onTap: onLogout,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isOpen ? 16 : 12,
                    vertical: 12,
                  ),
                  child: isOpen
                      ? Row(
                          children: [
                            Icon(
                              Icons.logout,
                              size: 20,
                              color: AppColors.softWhite.withOpacity(0.7),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Logout',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.softWhite.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Icon(
                            Icons.logout,
                            size: 22,
                            color: AppColors.softWhite.withOpacity(0.7),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String navId,
  }) {
    final isActive = activeNav == navId;

    return Tooltip(
      message: isOpen ? '' : label,
      child: InkWell(
        onTap: () => onNavChange(navId),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: EdgeInsets.symmetric(
            horizontal: isOpen ? 16 : 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.richGold.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isActive
                ? Border(
                    left: BorderSide(
                      color: AppColors.richGold,
                      width: 3,
                    ),
                  )
                : const Border(
                    left: BorderSide(
                      color: Colors.transparent,
                      width: 3,
                    ),
                  ),
          ),
          child: isOpen
              ? Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: isActive
                          ? AppColors.richGold
                          : AppColors.softWhite.withOpacity(0.7),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isActive
                            ? AppColors.richGold
                            : AppColors.softWhite.withOpacity(0.9),
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Icon(
                    icon,
                    size: 22,
                    color: isActive
                        ? AppColors.richGold
                        : AppColors.softWhite.withOpacity(0.7),
                  ),
                ),
        ),
      ),
    );
  }
}
