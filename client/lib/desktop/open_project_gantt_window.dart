import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';

import '../features/project/models/task.dart';
import 'window_startup_args.dart';

Future<void> openProjectGanttWindow({
  required BuildContext context,
  required int projectId,
  required String projectName,
  required String projectStartDate,
  required String projectDeadline,
  List<Task>? tasks,
}) async {
  if (!isDesktopMultiWindowSupported()) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(content: Text('Full Gantt opens in a separate window on desktop.')),
    );
    return;
  }
  try {
    final controller = await WindowController.create(
      WindowConfiguration(
        arguments: jsonEncode(
          WindowStartupArgs.ganttPayload(
            projectId: projectId,
            projectName: projectName,
            projectStartDate: projectStartDate,
            projectDeadline: projectDeadline,
            tasks: tasks,
          ),
        ),
      ),
    );
    await controller.show();
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text('Could not open Gantt window: $e')),
    );
  }
}
