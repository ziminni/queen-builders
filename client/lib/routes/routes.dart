// lib/routes/routes.dart
// import 'package:flutter/material.dart';
import 'package:client/features/admin/view/admin_dashboard.dart';
import 'package:client/features/admin/widgets/admin_sidebar.dart';
import 'package:go_router/go_router.dart';
import 'package:client/features/auth/view/login_screen.dart';
import 'package:client/features/auth/view/register_screen.dart';
import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:client/features/inventory/view/inventory_dashboard.dart';
import 'package:client/features/pos/view/pos_dashboard.dart';
// import 'package:client/features/project_management/view/project_dashboard.dart';
// import 'package:client/features/reports/view/reports_dashboard.dart';

class AppRoutes {
  static const String login = "/login";
  static const String register = "/register";
  
  // static const String admindashboard = "/admin/dashboard";
  static const String admindashboard = "/admin/dashboard";
  static const String inventoryDashboard = "/inventory/dashboard";
  static const String posDashboard = "/pos/dashboard";
  static const String projectDashboard = "/project/dashboard";
  static const String reportsDashboard = "/reports/dashboard";
  
  static GoRouter createRouter(AuthViewModel authViewModel) {
    return GoRouter(
      initialLocation: login,
      refreshListenable: authViewModel, // Listen to auth state changes
      redirect: (context, state) {
        final isAuthenticated = authViewModel.isAuthenticated;
        final isLoginRoute = state.matchedLocation == login;
        final isRegisterRoute = state.matchedLocation == register;
        
        // Not authenticated - redirect to login
        if (!isAuthenticated && !isLoginRoute && !isRegisterRoute) {
          return login;
        }
        
        // Authenticated - redirect to dashboard
        if (isAuthenticated && (isLoginRoute || isRegisterRoute)) {
          return getDashboardRoute(authViewModel.userRole);
        }
        
        // Stay on current route
        return null;
      },
      routes: [
        GoRoute(path: login, name: 'login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: register, name: 'register', builder: (context, state) => const RegisterScreen()),
        // GoRoute(path: admindashboard, name: 'admin', builder:(context, state) => const AdminDashboard(),),

        GoRoute(path: admindashboard, name: 'admin', builder: (context, state) => const AdminHomePage(),),
        GoRoute(path: inventoryDashboard, name: 'inventory', builder: (context, state) => const InventoryDashboard()),
        GoRoute(path: posDashboard, name: 'pos', builder: (context, state) => const PosDashboard()),
        // GoRoute(path: projectDashboard, name: 'project', builder: (context, state) => const ProjectDashboard()),
        // GoRoute(path: reportsDashboard, name: 'reports', builder: (context, state) => const ReportsDashboard()),
      ],
    );
  }
  
  static String getDashboardRoute(String? role) {
    switch (role) {
      case 'admin':
        return admindashboard;
      case 'manager':
        return inventoryDashboard;
      case 'cashier':
        return posDashboard;
      case 'project_supervisor':
        return projectDashboard;
      default:
        return inventoryDashboard;
    }
  }
}