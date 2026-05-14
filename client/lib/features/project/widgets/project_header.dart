import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ProjectHeader extends StatelessWidget {
  final VoidCallback onMenuToggle;
  final VoidCallback onLogout;
  final VoidCallback? onSettings;

  const ProjectHeader({
    super.key,
    required this.onMenuToggle,
    required this.onLogout,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFD9D9D9), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Menu Toggle & Title
          IconButton(
            onPressed: onMenuToggle,
            icon: const Icon(Icons.dashboard_outlined),
            color: const Color(0xFF8A8A8A),
            iconSize: 20,
          ),
          const SizedBox(width: 16),
          Text(
            'Project Dashboard',
            style: AppTextStyles.h2.copyWith(
              fontFamily: AppTextStyles.cinzelFont,
              color: AppColors.deepBlack,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          // Notifications
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
            color: const Color(0xFF8A8A8A),
            iconSize: 20,
          ),

          const SizedBox(width: 8),

          // Settings
          if (onSettings != null)
            IconButton(
              onPressed: onSettings,
              icon: const Icon(Icons.settings_outlined),
              color: const Color(0xFF8A8A8A),
              iconSize: 20,
              tooltip: 'Admin Settings',
            ),

          const SizedBox(width: 8),

          // Logout Button
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onLogout,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD9D9D9), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout,
                      size: 16,
                      color: Color(0xFF2B2B2B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: const Color(0xFF2B2B2B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
