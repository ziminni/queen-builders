import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class StoreCashierDetails extends StatelessWidget {
  final String userName;
  final String userRole;
  final String userInitials;

  const StoreCashierDetails({
    super.key,
    required this.userName,
    required this.userRole,
    required this.userInitials,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.richGold, width: 2),
      ),
      title: Text(
        'Store Cashier Details',
        style: AppTextStyles.h3.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.richGold,
              child: Text(
                userInitials,
                style: AppTextStyles.h2.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: AppTextStyles.h3.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userRole,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.richGold.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Employee ID', 'EMP-2024-0156'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Department', 'Retail Operations'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Current Shift', '8:00 AM - 5:00 PM'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Email', 'maria.santos@queenbuilders.com'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Contact', '+63 917 123 4567'),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.richGold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Close',
              style: AppTextStyles.button.copyWith(
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.deepBlack,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  static void show(
    BuildContext context, {
    required String userName,
    required String userRole,
    required String userInitials,
  }) {
    showDialog(
      context: context,
      builder: (context) => StoreCashierDetails(
        userName: userName,
        userRole: userRole,
        userInitials: userInitials,
      ),
    );
  }
}
