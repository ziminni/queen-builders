import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../features/project/models/task.dart';

/// Parsed payload from [WindowController.arguments] for desktop_multi_window.
class WindowStartupArgs {
  static const keyType = 'type';
  static const typeGantt = 'gantt';

  final String type;
  final int? projectId;
  final String projectName;
  final List<Task> scheduleTasks;
  final String projectStartDate;
  final String projectDeadline;

  WindowStartupArgs._({
    required this.type,
    this.projectId,
    this.projectName = '',
    this.scheduleTasks = const [],
    this.projectStartDate = '',
    this.projectDeadline = '',
  });

  factory WindowStartupArgs.main() => WindowStartupArgs._(type: 'main');

  factory WindowStartupArgs.fromEngineArguments(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return WindowStartupArgs.main();
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        final t = decoded[keyType] as String?;
        if (t == typeGantt) {
          final rawId = decoded['projectId'];
          final id = rawId is int ? rawId : int.tryParse('$rawId');
          if (id != null) {
            final tasks = <Task>[];
            final tasksRaw = decoded['tasks'];
            if (tasksRaw is List<dynamic>) {
              for (final e in tasksRaw) {
                if (e is Map<String, dynamic>) {
                  tasks.add(Task.fromJson(e));
                } else if (e is Map) {
                  tasks.add(Task.fromJson(Map<String, dynamic>.from(e)));
                }
              }
            }
            return WindowStartupArgs._(
              type: typeGantt,
              projectId: id,
              projectName: decoded['projectName'] as String? ?? '',
              scheduleTasks: tasks,
              projectStartDate: decoded['projectStartDate'] as String? ?? '',
              projectDeadline: decoded['projectDeadline'] as String? ?? '',
            );
          }
        }
      }
    } catch (_) {}
    return WindowStartupArgs.main();
  }

  bool get isGanttWindow => type == typeGantt && projectId != null;

  static Map<String, dynamic> ganttPayload({
    required int projectId,
    required String projectName,
    required String projectStartDate,
    required String projectDeadline,
    List<Task>? tasks,
  }) =>
      {
        keyType: typeGantt,
        'projectId': projectId,
        'projectName': projectName,
        'projectStartDate': projectStartDate,
        'projectDeadline': projectDeadline,
        'tasks': tasks?.map((t) => t.toJson()).toList() ?? <Map<String, dynamic>>[],
      };
}

bool isDesktopMultiWindowSupported() {
  if (kIsWeb) return false;
  switch (defaultTargetPlatform) {
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return true;
    default:
      return false;
  }
}
