import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = product.stock <= 0;

    return InkWell(
      onTap: isOutOfStock ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isOutOfStock ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isOutOfStock ? Colors.grey.shade300 : AppColors.border,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isOutOfStock
                    ? Colors.grey.shade200
                    : AppColors.richGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                product.category,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isOutOfStock ? Colors.grey : AppColors.richGold,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 6),

            // Product Name
            Text(
              product.name,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: isOutOfStock ? Colors.grey : AppColors.textPrimary,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 6),

            // Stock Info
            Text(
              'Stock: ${product.stock}',
              style: AppTextStyles.bodySmall.copyWith(
                color: isOutOfStock ? Colors.red : AppColors.textSecondary,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 8),

            // Price
            Text(
              '₱${product.sellingPrice.toStringAsFixed(2)}',
              style: AppTextStyles.h4.copyWith(
                color: isOutOfStock ? Colors.grey : AppColors.richGold,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            // Out of Stock Badge
            if (isOutOfStock) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    'OUT OF STOCK',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
