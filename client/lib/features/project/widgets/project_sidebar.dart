import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ProjectSidebar extends StatelessWidget {
  final bool isOpen;
  final String activeNav;
  final Function(String) onNavChanged;

  const ProjectSidebar({
    super.key,
    required this.isOpen,
    required this.activeNav,
    required this.onNavChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isOpen ? 260 : 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFD9D9D9), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFD9D9D9), width: 1),
              ),
            ),
            child: isOpen ? _buildExpandedLogo() : _buildCollapsedLogo(),
          ),

          // Navigation
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildNavItem(
                  icon: Icons.business,
                  label: 'Projects',
                  id: 'projects',
                ),
                const SizedBox(height: 8),
                _buildNavItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Materials',
                  id: 'materials',
                ),
                const SizedBox(height: 8),
                _buildNavItem(
                  icon: Icons.people_outline,
                  label: 'Team',
                  id: 'team',
                ),
                const SizedBox(height: 8),
                _buildNavItem(
                  icon: Icons.description_outlined,
                  label: 'Reports',
                  id: 'reports',
                ),
                const SizedBox(height: 8),
                _buildNavItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  id: 'settings',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedLogo() {
    return Row(
      children: [
        // QB Logo Box
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x1AC5A46D),
                Color(0x1A8C6B3F),
              ],
            ),
            border: Border.all(color: AppColors.richGold, width: 2),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.richGold, width: 1),
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  'QB',
                  style: AppTextStyles.h3.copyWith(
                    fontFamily: AppTextStyles.cinzelFont,
                    color: AppColors.richGold,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Queen Builders',
                style: TextStyle(
                  fontFamily: AppTextStyles.cinzelFont,
                  color: AppColors.deepBlack,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                'Project Manager',
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF8A8A8A),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedLogo() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x1AC5A46D),
            Color(0x1A8C6B3F),
          ],
        ),
        border: Border.all(color: AppColors.richGold, width: 2),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.richGold, width: 1),
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              'QB',
              style: AppTextStyles.h3.copyWith(
                fontFamily: AppTextStyles.cinzelFont,
                color: AppColors.richGold,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String id,
  }) {
    final isActive = activeNav == id;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onNavChanged(id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.richGold.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? AppColors.richGold : const Color(0xFF2B2B2B),
              ),
              if (isOpen) ...[
                const SizedBox(width: 12),
                Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isActive ? AppColors.richGold : const Color(0xFF2B2B2B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
