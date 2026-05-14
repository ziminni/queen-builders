import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../routes/routes.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../models/admin_menu_item.dart';

class AdminSidebar extends StatelessWidget {
  final bool isExpanded;
  final int selectedIndex;
  final List<AdminMenuItem> menuItems;
  final ValueChanged<int> onItemSelected;

  const AdminSidebar({
    super.key,
    required this.isExpanded,
    required this.selectedIndex,
    required this.menuItems,
    required this.onItemSelected,
  });

  static const List<AdminMenuItem> defaultMenuItems = [
    AdminMenuItem(icon: Icons.manage_accounts_outlined, label: 'User management', index: 0),
    AdminMenuItem(icon: Icons.fact_check_outlined, label: 'Audit logs', index: 1),
    AdminMenuItem(icon: Icons.tune_outlined, label: 'System management', index: 2),
  ];

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Logout', style: AppTextStyles.h3),
        content: Text('Sign out of the admin portal?', style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppTextStyles.button.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Logout', style: AppTextStyles.button.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    await context.read<AuthViewModel>().logout();
    if (context.mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      width: isExpanded ? 260 : 76,
      decoration: BoxDecoration(
        color: AppColors.deepBlack,
        border: Border(
          right: BorderSide(color: AppColors.border.withValues(alpha: 0.25)),
        ),
      ),
      child: Column(
        children: [
          _brand(context),
          const Divider(height: 1, color: Colors.white24),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              itemCount: menuItems.length,
              itemBuilder: (context, i) {
                final item = menuItems[i];
                final selected = selectedIndex == item.index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onItemSelected(item.index),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isExpanded ? 14 : 10,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.richGold.withValues(alpha: 0.18)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border(
                            left: BorderSide(
                              color: selected ? AppColors.richGold : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 22,
                              color: selected
                                  ? AppColors.richGold
                                  : AppColors.softWhite.withValues(alpha: 0.65),
                            ),
                            if (isExpanded) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: selected
                                        ? AppColors.richGold
                                        : AppColors.softWhite.withValues(alpha: 0.88),
                                    fontWeight:
                                        selected ? FontWeight.w600 : FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Colors.white24),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: Tooltip(
              message: isExpanded ? '' : 'Logout',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _confirmLogout(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isExpanded ? 14 : 10,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout,
                          size: 22,
                          color: AppColors.softWhite.withValues(alpha: 0.65),
                        ),
                        if (isExpanded) ...[
                          const SizedBox(width: 12),
                          Text(
                            'Logout',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.softWhite.withValues(alpha: 0.75),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
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

  Widget _brand(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [
                  AppColors.richGold,
                  AppColors.richGold.withValues(alpha: 0.75),
                ],
              ),
            ),
            child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 22),
          ),
          if (isExpanded) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Queen Builders',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.softWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'ADMIN CONSOLE',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.richGold,
                      letterSpacing: 1.1,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
