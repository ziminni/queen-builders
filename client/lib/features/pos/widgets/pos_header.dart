import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class POSHeader extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final int notificationCount;

  const POSHeader({
    super.key,
    this.onNotificationTap,
    this.onProfileTap,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.deepBlack,
        border: Border(
          bottom: BorderSide(
            color: AppColors.richGold.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // QB Logo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.richGold, width: 2),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.richGold.withOpacity(0.1),
                  AppColors.richGold.withOpacity(0.05),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.richGold),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'QB',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.richGold,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Point of Sale',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.softWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'STORE CASHIER',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.richGold,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Material Requests Notification
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 20),
            color: AppColors.softWhite.withOpacity(0.7),
            onPressed: onNotificationTap,
            tooltip: 'Material Requests',
          ),

          const SizedBox(width: 4),

          // Fulfillment Receipts Notification
          IconButton(
            icon: const Icon(Icons.receipt_outlined, size: 20),
            color: AppColors.softWhite.withOpacity(0.7),
            onPressed: onNotificationTap,
            tooltip: 'Fulfillment Receipts',
          ),

          const SizedBox(width: 8),

          // Profile
          InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Cashier: Maria Santos',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.softWhite,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: AppColors.richGold,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Shift: 8:00 AM - 5:00 PM',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.richGold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.richGold,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
