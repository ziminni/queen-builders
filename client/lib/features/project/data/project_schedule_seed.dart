import 'package:intl/intl.dart';

import '../models/task.dart';
import '../utils/wbs_utils.dart';

final _dayFmt = DateFormat('yyyy-MM-dd');

/// Fallback schedule when no tasks are loaded yet (matches project timeline).
///
/// WBS convention:
/// - Whole numbers (`1`, `2`) — category / summary rows at 100% rolled-up display.
/// - Decimals (`1.1`, `2.2`) — tasks under that category (parts of the category).
List<Task> seedScheduleTasks({
  required int projectId,
  required String projectStartDate,
  required String projectDeadline,
}) {
  DateTime start;
  DateTime end;
  try {
    start = DateTime.parse(projectStartDate);
    end = DateTime.parse(projectDeadline);
  } catch (_) {
    final n = DateTime.now();
    start = DateTime(n.year, n.month, n.day);
    end = start.add(const Duration(days: 120));
  }
  if (!end.isAfter(start)) {
    end = start.add(const Duration(days: 120));
  }

  final span = end.difference(start).inDays;
  final safeSpan = span < 7 ? 60 : span;

  DateTime at(double t) => start.add(Duration(days: (safeSpan * t).round()));

  String fmt(DateTime d) => _dayFmt.format(d);

  final p = 'seed_$projectId';

  // --- Structure (1): category + subtasks ---
  final s1Id = '${p}_wbs_1';
  final t11Start = at(0.04);
  final t11End = at(0.22);
  final t12Start = at(0.18);
  final t12End = at(0.44);

  final structureDig = Task(
    id: '${p}_1_1',
    projectId: projectId,
    name: 'Digging & positioning / earthwork',
    wbs: '1.1',
    parentId: s1Id,
    startDate: fmt(t11Start),
    endDate: fmt(t11End),
    progress: 100,
    category: 'Labor',
    dependencies: const [],
    isMilestone: false,
    isSummary: false,
  );

  final structureShell = Task(
    id: '${p}_1_2',
    projectId: projectId,
    name: 'Foundation pour & structural shell',
    wbs: '1.2',
    parentId: s1Id,
    startDate: fmt(t12Start),
    endDate: fmt(t12End),
    progress: 72,
    category: 'Labor',
    dependencies: [structureDig.id],
    isMilestone: false,
    isSummary: false,
  );

  final envelopeStart = t11Start.isBefore(t12Start) ? t11Start : t12Start;
  final envelopeEnd = t11End.isAfter(t12End) ? t11End : t12End;

  final structureSummary = Task(
    id: s1Id,
    projectId: projectId,
    name: 'Structure',
    wbs: '1',
    parentId: null,
    startDate: fmt(envelopeStart),
    endDate: fmt(envelopeEnd),
    progress: 100,
    category: null,
    dependencies: const [],
    isMilestone: false,
    isSummary: true,
  );

  // --- Roofing (2): category + subtasks ---
  final s2Id = '${p}_wbs_2';
  final t21Start = at(0.40);
  final t21End = at(0.62);
  final t22Start = at(0.56);
  final t22End = at(0.78);

  final roofingDryIn = Task(
    id: '${p}_2_1',
    projectId: projectId,
    name: 'Dry-in & underlayment',
    wbs: '2.1',
    parentId: s2Id,
    startDate: fmt(t21Start),
    endDate: fmt(t21End),
    progress: 85,
    category: 'Labor',
    dependencies: [structureShell.id],
    isMilestone: false,
    isSummary: false,
  );

  final roofingFinish = Task(
    id: '${p}_2_2',
    projectId: projectId,
    name: 'Final roofing & flashings',
    wbs: '2.2',
    parentId: s2Id,
    startDate: fmt(t22Start),
    endDate: fmt(t22End),
    progress: 45,
    category: 'Labor',
    dependencies: [roofingDryIn.id],
    isMilestone: false,
    isSummary: false,
  );

  final roofEnvStart = t21Start.isBefore(t22Start) ? t21Start : t22Start;
  final roofEnvEnd = t21End.isAfter(t22End) ? t21End : t22End;

  final roofingSummary = Task(
    id: s2Id,
    projectId: projectId,
    name: 'Roofing',
    wbs: '2',
    parentId: null,
    startDate: fmt(roofEnvStart),
    endDate: fmt(roofEnvEnd),
    progress: 100,
    category: null,
    dependencies: const [],
    isMilestone: false,
    isSummary: true,
  );

  // --- Close-out milestone ---
  final milestoneStart = at(0.94);
  final milestone = Task(
    id: '${p}_milestone',
    projectId: projectId,
    name: 'Substantial completion',
    wbs: '3',
    parentId: null,
    startDate: fmt(milestoneStart),
    endDate: fmt(milestoneStart),
    progress: 0,
    category: 'Misc',
    dependencies: [roofingFinish.id],
    isMilestone: true,
    isSummary: false,
  );

  final flat = [
    structureSummary,
    structureDig,
    structureShell,
    roofingSummary,
    roofingDryIn,
    roofingFinish,
    milestone,
  ];

  return orderTasksForGantt(flat);
}
