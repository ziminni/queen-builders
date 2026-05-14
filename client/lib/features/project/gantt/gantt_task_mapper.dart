import 'package:legacy_gantt_chart/legacy_gantt_chart.dart';

import '../models/task.dart';

DateTime _parseLocalDate(String raw) {
  return DateTime.parse(raw);
}

/// One row per schedule task ([Task.id] is both row and bar key).
List<LegacyGanttRow> legacyRowsForTasks(List<Task> tasks) {
  return tasks
      .map((t) => LegacyGanttRow(
            id: t.id,
            label: t.wbs.isNotEmpty ? '${t.wbs} · ${t.name}' : t.name,
          ))
      .toList();
}

Map<String, int> rowDepthForTasks(List<Task> tasks) => {
      for (final t in tasks) t.id: 1,
    };

List<LegacyGanttTask> legacyGanttTasksFromTasks(List<Task> tasks) {
  return tasks.map((t) {
    final start = _parseLocalDate(t.startDate);
    var end = _parseLocalDate(t.endDate);
    if (t.isMilestone) {
      return LegacyGanttTask(
        id: t.id,
        rowId: t.id,
        name: t.name,
        start: start,
        end: start.add(const Duration(days: 1)),
        isMilestone: true,
        isSummary: false,
        completion: (t.progress.clamp(0, 100)) / 100.0,
      );
    }
    if (!end.isAfter(start)) {
      end = start.add(const Duration(days: 1));
    }
    return LegacyGanttTask(
      id: t.id,
      rowId: t.id,
      name: t.name,
      start: start,
      end: end,
      isSummary: t.isSummary,
      propagatesMoveToChildren: t.isSummary,
      completion: (t.progress.clamp(0, 100)) / 100.0,
    );
  }).toList();
}

List<LegacyGanttTaskDependency> legacyDependenciesFromTasks(List<Task> tasks) {
  final ids = tasks.map((t) => t.id).toSet();
  final out = <LegacyGanttTaskDependency>[];
  for (final t in tasks) {
    if (t.isSummary) continue;
    for (final predId in t.dependencies) {
      if (ids.contains(predId)) {
        out.add(LegacyGanttTaskDependency(
          predecessorTaskId: predId,
          successorTaskId: t.id,
          type: DependencyType.finishToStart,
        ));
      }
    }
  }
  return out;
}
