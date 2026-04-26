// lib/features/dashboard/view/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../../routes/routes.dart';

class ProjectDashboard extends StatelessWidget {
  const ProjectDashboard({super.key});
  
  Future<void> _handleLogout(BuildContext context) async {
    await context.read<AuthViewModel>().logout();
    if (context.mounted) {
      context.go(AppRoutes.login);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Dashboard'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Show confirmation dialog
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              
              if (confirm == true && context.mounted) {
                await _handleLogout(context);
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome Project!'),
      ),
    );
  }
}

// Create similar for manager_dashboard.dart, cashier_dashboard.dart, supervisor_dashboard.dart