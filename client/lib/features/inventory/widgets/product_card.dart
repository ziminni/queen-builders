import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Item Code & Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.itemCode,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.richGold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _buildStockBadge(product.stockStatus),
              ],
            ),

            const SizedBox(height: 12),

            // Product Name
            Text(
              product.name,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Brand & Category
            Row(
              children: [
                Icon(
                  Icons.business,
                  size: 14,
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    product.brand,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Row(
              children: [
                Icon(
                  Icons.category,
                  size: 14,
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    product.category,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Divider
            Container(
              height: 1,
              color: AppColors.border,
            ),

            const SizedBox(height: 16),

            // Price & Stock
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₱${product.sellingPrice.toStringAsFixed(2)}',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.richGold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'In Stock',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.stock} ${product.unit}',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: _getStockColor(product.stockStatus),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: onEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.richGold,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.edit, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Edit Product',
                      style: AppTextStyles.button.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockBadge(StockStatus status) {
    final badgeData = _getStockBadgeData(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeData['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeData['icon'],
            size: 12,
            color: badgeData['color'],
          ),
          const SizedBox(width: 4),
          Text(
            badgeData['label'],
            style: AppTextStyles.labelSmall.copyWith(
              color: badgeData['color'],
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStockBadgeData(StockStatus status) {
    switch (status) {
      case StockStatus.ok:
        return {
          'label': 'OK',
          'color': AppColors.stockOk,
          'icon': Icons.check_circle,
        };
      case StockStatus.low:
        return {
          'label': 'LOW',
          'color': AppColors.stockLow,
          'icon': Icons.warning,
        };
      case StockStatus.critical:
        return {
          'label': 'CRITICAL',
          'color': AppColors.stockCritical,
          'icon': Icons.error,
        };
    }
  }

  Color _getStockColor(StockStatus status) {
    switch (status) {
      case StockStatus.ok:
        return AppColors.stockOk;
      case StockStatus.low:
        return AppColors.stockLow;
      case StockStatus.critical:
        return AppColors.stockCritical;
    }
  }
}
