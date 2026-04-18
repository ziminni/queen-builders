// lib/features/dashboard/view/admin_dashboard.dart
import 'package:flutter/material.dart';

class ProjectDashboard extends StatelessWidget {
  const ProjectDashboard({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Dashboard'),
        centerTitle: false,
      ),
      body: Center(
        child: Text('Welcome Project!'),
      ),
    );
  }
}

// Create similar for manager_dashboard.dart, cashier_dashboard.dart, supervisor_dashboard.dart