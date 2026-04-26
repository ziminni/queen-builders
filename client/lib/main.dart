// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:client/features/pos/viewmodels/pos_viewmodel.dart';
import 'package:client/features/inventory/viewmodels/inventory_viewmodel.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window manager for desktop
  await windowManager.ensureInitialized();
  
  // Set minimum window size (prevents layout breaking)
  await windowManager.setMinimumSize(const Size(1000, 600));
  
  // Set default window size
  await windowManager.setSize(const Size(1200, 700));
  
  // Center window on screen
  await windowManager.center();
  
  // Make window resizable but with minimum constraint
  await windowManager.setResizable(true);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => POSViewModel()),
        ChangeNotifierProvider(create: (_) => InventoryViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}