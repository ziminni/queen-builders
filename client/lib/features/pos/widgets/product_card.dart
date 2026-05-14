import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/product.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final bool isOutOfStock = product.stock <= 0;
    final bool lowStock =
        !isOutOfStock && product.stock > 0 && product.stock <= product.reorderLevel;

    final borderColor = isOutOfStock
        ? AppColors.border
        : _hover
            ? AppColors.richGold.withValues(alpha: 0.65)
            : AppColors.border.withValues(alpha: 0.85);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: isOutOfStock ? MouseCursor.defer : SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: isOutOfStock
              ? null
              : [
                  BoxShadow(
                    color: AppColors.richGold.withValues(alpha: _hover ? 0.12 : 0.07),
                    blurRadius: _hover ? 20 : 14,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: _hover ? 0.07 : 0.045),
                    blurRadius: _hover ? 12 : 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isOutOfStock ? null : widget.onTap,
            borderRadius: BorderRadius.circular(14),
            splashColor: AppColors.richGold.withValues(alpha: 0.12),
            highlightColor: AppColors.richGold.withValues(alpha: 0.06),
            child: Ink(
              decoration: BoxDecoration(
                color: isOutOfStock ? const Color(0xFFF0F0F0) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: isOutOfStock ? 1.5 : (_hover ? 2 : 1.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isOutOfStock
                            ? [
                                Colors.grey.shade400,
                                Colors.grey.shade300,
                              ]
                            : [
                                AppColors.richGold,
                                AppColors.richGold.withValues(alpha: 0.55),
                              ],
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isOutOfStock
                                  ? Colors.grey.shade300.withValues(alpha: 0.45)
                                  : AppColors.richGold.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isOutOfStock
                                    ? Colors.grey.shade400.withValues(alpha: 0.4)
                                    : AppColors.richGold.withValues(alpha: 0.22),
                              ),
                            ),
                            child: Text(
                              product.category,
                              style: AppTextStyles.labelSmall.copyWith(
                                color:
                                    isOutOfStock ? Colors.grey.shade700 : AppColors.richGold,
                                fontWeight: FontWeight.w700,
                                fontSize: 9.5,
                                letterSpacing: 0.35,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              product.name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                                color: isOutOfStock
                                    ? Colors.grey.shade600
                                    : AppColors.deepBlack,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.layers_outlined,
                                size: 14,
                                color: isOutOfStock
                                    ? Colors.grey
                                    : lowStock
                                        ? const Color(0xFFC07600)
                                        : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  isOutOfStock
                                      ? 'No stock'
                                      : lowStock
                                          ? '${product.stock} left · reorder soon'
                                          : '${product.stock} in stock',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isOutOfStock
                                        ? Colors.red.shade700
                                        : lowStock
                                            ? const Color(0xFFC07600)
                                            : AppColors.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₱${product.sellingPrice.toStringAsFixed(2)}',
                            style: AppTextStyles.h4.copyWith(
                              color: isOutOfStock ? Colors.grey.shade600 : AppColors.richGold,
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isOutOfStock)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(13),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'OUT OF STOCK',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.w800,
                          fontSize: 9.5,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
