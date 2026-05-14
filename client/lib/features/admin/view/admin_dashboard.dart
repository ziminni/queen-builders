import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../widgets/admin_dashboard_sections.dart';
import '../widgets/admin_header.dart';
import '../widgets/admin_sidebar.dart';

/// Admin console: user directory by role group, cross-module audit trail, system controls.
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _sidebarExpanded = true;
  int _section = 0;

  static const _titles = [
    'User management',
    'Audit logs',
    'System management',
  ];

  static const _subtitles = [
    'Accounts by role: Project manager, Stock manager, Cashier',
    'Separated by module and category — inventory, POS, and more',
    'Environment, data lifecycle, and operational controls',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminSidebar(
            isExpanded: _sidebarExpanded,
            selectedIndex: _section,
            menuItems: AdminSidebar.defaultMenuItems,
            onItemSelected: (i) => setState(() => _section = i),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdminHeader(
                  title: _titles[_section],
                  subtitle: _subtitles[_section],
                  sidebarExpanded: _sidebarExpanded,
                  onToggleSidebar: () =>
                      setState(() => _sidebarExpanded = !_sidebarExpanded),
                ),
                Expanded(child: _sectionContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionContent() {
    switch (_section) {
      case 0:
        return const AdminUserManagementContent();
      case 1:
        return const AdminAuditLogsContent();
      case 2:
        return const AdminSystemManagementContent();
      default:
        return Center(
          child: Text(
            'Unknown section',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        );
    }
  }
}
