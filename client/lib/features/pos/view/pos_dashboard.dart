// lib/features/dashboard/view/admin_dashboard.dart
import 'package:flutter/material.dart';

class PosDashboard extends StatelessWidget {
  const PosDashboard({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Dashboard'),
        centerTitle: false,
      ),
      body: Center(
        child: Text('POS Admin!'),
      ),
    );
  }
}

// Create similar for manager_dashboard.dart, cashier_dashboard.dart, supervisor_dashboard.dart