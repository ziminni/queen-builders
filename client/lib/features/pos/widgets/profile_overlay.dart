import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'store_cashier_details.dart';

class ProfileOverlay extends StatefulWidget {
  final String userName;
  final String userRole;
  final String userInitials;
  final VoidCallback? onLogout;

  const ProfileOverlay({
    super.key,
    required this.userName,
    required this.userRole,
    required this.userInitials,
    this.onLogout,
  });

  @override
  State<ProfileOverlay> createState() => _ProfileOverlayState();

  static void show(
    BuildContext context, {
    required String userName,
    required String userRole,
    required String userInitials,
    VoidCallback? onLogout,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Profile Overlay',
      barrierColor: Colors.black.withOpacity(0.25),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ProfileOverlay(
          userName: userName,
          userRole: userRole,
          userInitials: userInitials,
          onLogout: onLogout ?? () => Navigator.of(context).pop(),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _ProfileOverlayState extends State<ProfileOverlay> {
  bool _isArrowHovered = false;

  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }

  Widget _buildContent() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 350,
            margin: const EdgeInsets.only(top: 78, right: 383),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              border: Border.all(color: AppColors.richGold.withOpacity(0.7), width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // Header with user info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: AppColors.richGold,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF8F8F8),
                      ),
                      child: Center(
                        child: Text(
                          widget.userInitials,
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.richGold,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                          widget.userName,
                            style: AppTextStyles.h3.copyWith(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                          widget.userRole,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    MouseRegion(
                      onEnter: (_) => setState(() => _isArrowHovered = true),
                      onExit: (_) => setState(() => _isArrowHovered = false),
                      cursor: SystemMouseCursors.click,
                      child: InkWell(
                        onTap: () => _showStoreCashierDetails(context),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _isArrowHovered ? Colors.white.withOpacity(0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: _isArrowHovered ? Colors.white : Colors.white.withOpacity(0.8),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Recent Transactions section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Text(
                  'Recent Transactions',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.deepBlack,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 275,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.border.withOpacity(0.8)),
                    bottom: BorderSide(color: AppColors.border.withOpacity(0.8)),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 40,
                      color: AppColors.textSecondary.withOpacity(0.35),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No transactions yet',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary.withOpacity(0.85),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              // Logout button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: widget.onLogout,
                    icon: const Icon(Icons.logout, size: 20),
                    label: Text(
                      'Logout',
                      style: AppTextStyles.h4.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2C2A2D),
                      side: BorderSide(color: AppColors.border.withOpacity(0.95)),
                      backgroundColor: const Color(0xFFF3F3F3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  void _showStoreCashierDetails(BuildContext context) {
    // Close the profile overlay first
    Navigator.of(context).pop();

    // Then show the store cashier details dialog
    StoreCashierDetails.show(
      context,
      userName: widget.userName,
      userRole: widget.userRole,
      userInitials: widget.userInitials,
    );
  }
}
