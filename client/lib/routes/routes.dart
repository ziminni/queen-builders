// lib/routes/routes.dart
import 'package:flutter/material.dart';
import 'package:client/features/admin/view/admin_dashboard.dart';
import 'package:client/features/inventory/view/all_products_page.dart';
import 'package:go_router/go_router.dart';
import 'package:client/features/auth/view/login_screen.dart';
import 'package:client/features/auth/view/register_screen.dart';
import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:client/features/inventory/view/inventory_dashboard.dart';
import 'package:client/features/pos/view/pos_dashboard.dart';
import 'package:client/features/project/view/project_dashboard.dart';
// import 'package:client/features/reports/view/reports_dashboard.dart';

class AppRoutes {
  static const String login = "/login";
  static const String register = "/register";
  
  // static const String admindashboard = "/admin/dashboard";
  static const String admindashboard = "/admin/dashboard";
  static const String inventoryDashboard = "/inventory/dashboard";
  static const String inventoryProducts = "/inventory/products";
  static const String stockManager = "/inventory/dashboard";
  static const String stockManagerProducts = "/inventory/products";
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

        GoRoute(path: admindashboard, name: 'admin', builder: (context, state) => const AdminDashboard(),),
        GoRoute(
          path: inventoryDashboard,
          name: 'inventory',
          pageBuilder: (context, state) => _buildInventoryTransitionPage(
            state: state,
            child: const InventoryDashboard(),
          ),
        ),
        GoRoute(
          path: inventoryProducts,
          name: 'inventory-products',
          pageBuilder: (context, state) => _buildInventoryTransitionPage(
            state: state,
            child: const AllProductsPage(),
          ),
        ),
        GoRoute(path: posDashboard, name: 'pos', builder: (context, state) => const POSDashboard()),
        GoRoute(path: projectDashboard, name: 'project', builder: (context, state) => const ProjectDashboard()),
        // GoRoute(path: reportsDashboard, name: 'reports', builder: (context, state) => const ReportsDashboard()),
      ],
    );
  }
  
  static String getDashboardRoute(String? role) {
    switch (role) {
      case 'admin':
        return admindashboard;
      case 'stockManager':
        return inventoryDashboard;
      case 'cashier':
        return posDashboard;
      case 'projectManager':
        return projectDashboard;
      default:
        return posDashboard;
    }
  }

  static CustomTransitionPage<void> _buildInventoryTransitionPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.02, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}