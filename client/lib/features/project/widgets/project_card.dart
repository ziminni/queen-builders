import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/project.dart';

class ProjectCard extends StatefulWidget {
  final Project project;
  final double totalBudget;
  final double totalExpenses;
  final int criticalIssues;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.totalBudget,
    required this.totalExpenses,
    required this.criticalIssues,
    required this.onTap,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _isHovered = false;

  Color _getStatusColor() {
    switch (widget.project.status) {
      case 'In Progress':
        return const Color(0xFF3B82F6);
      case 'Planning':
        return const Color(0xFFF59E0B);
      case 'On Hold':
        return const Color(0xFFEF4444);
      case 'Completed':
        return const Color(0xFF10B981);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,##0', 'en_US');
    final dateFormat = DateFormat('M/d/yyyy');

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Align(
          alignment: Alignment.topCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isHovered
                    ? AppColors.richGold
                    : const Color(0xFFE0E0E0),
                width: 2,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: AppColors.richGold.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status and Critical Issues
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.project.status,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (widget.criticalIssues > 0)
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.criticalIssues}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Project Name
                Text(
                  widget.project.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h3.copyWith(
                    fontFamily: AppTextStyles.cinzelFont,
                    color: AppColors.deepBlack,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 16),

                // Client
                Row(
                  children: [
                    const Icon(
                      Icons.business,
                      size: 16,
                      color: AppColors.richGold,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.project.client,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF2B2B2B),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Foreman
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppColors.richGold,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Foreman: ${widget.project.foreman}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF2B2B2B),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.richGold,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.project.location,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF2B2B2B),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF8A8A8A),
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          '${widget.project.progress}%',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.richGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: widget.project.progress / 100,
                        backgroundColor: const Color(0xFFD9D9D9),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.richGold,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Budget vs Expenses
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF8A8A8A),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₱${numberFormat.format(widget.totalBudget)}',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.deepBlack,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Spent',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF8A8A8A),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₱${numberFormat.format(widget.totalExpenses)}',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Timeline
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Color(0xFF8A8A8A),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${dateFormat.format(DateTime.parse(widget.project.startDate))} - ${dateFormat.format(DateTime.parse(widget.project.deadline))}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF8A8A8A),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
