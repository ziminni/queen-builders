import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/inventory_categories.dart';
import '../viewmodels/inventory_viewmodel.dart';
import 'add_product_dialog.dart';
import 'manage_products_catalog_dialog.dart';

/// “Manage Products” (All Products header only): menu with Add product · View all products.
/// Uses [FilledButton] with the same padding and shape as “Receive Delivery”
/// [OutlinedButton.icon] on [AllProductsPage] so both controls share height.
class InventoryManageProductsMenuButton extends StatelessWidget {
  const InventoryManageProductsMenuButton({super.key});

  /// Keep in sync with Receive Delivery `OutlinedButton.styleFrom` on All Products.
  static final ButtonStyle _headerButtonStyle = FilledButton.styleFrom(
    elevation: 0,
    backgroundColor: AppColors.richGold,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryViewModel>(
      builder: (context, vm, _) {
        return MenuAnchor(
          consumeOutsideTap: true,
          style: MenuStyle(
            backgroundColor: const WidgetStatePropertyAll(Colors.white),
            elevation: const WidgetStatePropertyAll(6),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.richGold, width: 1.5),
              ),
            ),
          ),
          menuChildren: [
            MenuItemButton(
              leadingIcon: Icon(Icons.add_circle_outline,
                  size: 20, color: AppColors.richGold),
              style: MenuItemButton.styleFrom(foregroundColor: AppColors.textPrimary),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AddProductDialog(
                    categories: kInventoryProductCategories,
                    onCommit: vm.commitProductForm,
                  ),
                );
              },
              child: Text('Add product', style: AppTextStyles.bodyMedium),
            ),
            MenuItemButton(
              leadingIcon: Icon(Icons.inventory_2_outlined,
                  size: 20, color: AppColors.richGold),
              style: MenuItemButton.styleFrom(foregroundColor: AppColors.textPrimary),
              onPressed: () => showManageProductsCatalogDialog(context),
              child: Text('View all products', style: AppTextStyles.bodyMedium),
            ),
          ],
          builder: (context, controller, _) {
            return FilledButton(
              style: _headerButtonStyle,
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Manage Products',
                    style: AppTextStyles.button.copyWith(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 18),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
