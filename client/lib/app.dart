// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/core/scroll/desktop_smooth_scroll.dart';
import 'package:client/core/theme/app_theme.dart';
import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:client/routes/routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        // Create router with auth viewmodel for redirect logic
        final router = AppRoutes.createRouter(authViewModel);
        
        return MaterialApp.router(
          title: 'Hardware Store Management System',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          scrollBehavior: const DesktopSmoothScrollBehavior(),
          routerConfig: router,
        );
      },
    );
  }
}