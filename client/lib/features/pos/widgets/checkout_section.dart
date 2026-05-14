import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class CheckoutSection extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double total;
  final VoidCallback onPayLaterPayment;
  final VoidCallback onCashPayment;
  final bool hasItems;

  const CheckoutSection({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.onPayLaterPayment,
    required this.onCashPayment,
    required this.hasItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Subtotal
          _buildPriceRow('Subtotal', subtotal, false),
          const SizedBox(height: 8),

          // Tax (12% VAT)
          _buildPriceRow('VAT (12%)', tax, false),
          const SizedBox(height: 8),

          // Divider
          const Divider(color: AppColors.border, thickness: 1),
          const SizedBox(height: 8),

          // Total
          _buildPriceRow('Total', total, true),

          const SizedBox(height: 20),

          // Payment Buttons
          ElevatedButton.icon(
            onPressed: hasItems ? onPayLaterPayment : null,
            icon: const Icon(Icons.handshake_outlined, size: 20),
            label: Text(
              'Pay-Later Payment',
              style: AppTextStyles.button.copyWith(fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasItems ? AppColors.richGold : AppColors.border,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
              disabledBackgroundColor: AppColors.border,
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          const SizedBox(height: 8),

          OutlinedButton.icon(
            onPressed: hasItems ? onCashPayment : null,
            icon: const Icon(Icons.attach_money, size: 20),
            label: Text(
              'Cash Payment',
              style: AppTextStyles.button.copyWith(
                fontSize: 15,
                color: hasItems ? AppColors.richGold : AppColors.textSecondary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(
                color: hasItems ? AppColors.richGold : AppColors.border,
                width: 2,
              ),
              foregroundColor: hasItems ? AppColors.richGold : AppColors.textSecondary,
              disabledForegroundColor: AppColors.textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.h3.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                )
              : AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
        ),
        Text(
          '₱${amount.toStringAsFixed(2)}',
          style: isTotal
              ? AppTextStyles.h2.copyWith(
                  color: AppColors.richGold,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                )
              : AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.deepBlack,
                  fontSize: 14,
                ),
        ),
      ],
    );
  }
}
