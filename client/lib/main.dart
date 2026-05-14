// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:client/core/audit/audit_log_viewmodel.dart';
import 'package:client/features/admin/viewmodels/admin_users_viewmodel.dart';
import 'package:client/features/pos/viewmodels/pos_viewmodel.dart';
import 'package:client/features/inventory/viewmodels/inventory_viewmodel.dart';
import 'package:client/desktop/desktop_multi_window_bridge.dart';
import 'package:client/desktop/window_startup_args.dart';
import 'package:client/features/project/gantt/project_gantt_standalone.dart';
import 'app.dart';

import 'package:client/data/repositories/inventory_repository.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  var startup = WindowStartupArgs.main();
  if (isDesktopMultiWindowSupported()) {
    try {
      startup = await bootstrapDesktopMultiWindow();
    } catch (e, st) {
      debugPrint('desktop_multi_window bootstrap failed: $e\n$st');
    }
  }

  if (startup.isGanttWindow) {
    await windowManager.setMinimumSize(const Size(960, 640));
    await windowManager.setSize(const Size(1320, 820));
    await windowManager.center();
    await windowManager.setResizable(true);
    final label = startup.projectName.isEmpty
        ? 'Project ${startup.projectId}'
        : startup.projectName;
    await windowManager.setTitle('Gantt — $label');
    runApp(
      ProjectGanttStandaloneApp(
        projectId: startup.projectId!,
        projectName: startup.projectName,
        scheduleTasks: startup.scheduleTasks,
        projectStartDate: startup.projectStartDate,
        projectDeadline: startup.projectDeadline,
      ),
    );
    return;
  }

  await windowManager.setMinimumSize(const Size(1000, 600));
  await windowManager.setSize(const Size(1200, 700));
  await windowManager.center();
  await windowManager.setResizable(true);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuditLogViewModel()),
        ChangeNotifierProvider(
          create: (ctx) =>
              AuthViewModel(auditLog: ctx.read<AuditLogViewModel>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              AdminUsersViewModel(auditLog: ctx.read<AuditLogViewModel>()),
        ),
        Provider<InventoryRepository>(create: (_) => InventoryRepository()),
        ChangeNotifierProvider(
          create: (ctx) => InventoryViewModel(
            auditLog: ctx.read<AuditLogViewModel>(),
            repository: ctx.read<InventoryRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => POSViewModel(
            auditLog: ctx.read<AuditLogViewModel>(),
            inventoryRepository: ctx.read<InventoryRepository>(),
            inventoryViewModel: ctx.read<InventoryViewModel>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
