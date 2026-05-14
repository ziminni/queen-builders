import '../models/task.dart';

/// Sort order: `1`, `1.1`, `1.2`, `2`, `2.1`, … (numeric segments).
int compareWbs(String a, String b) {
  final aa = _wbsSegments(a);
  final bb = _wbsSegments(b);
  final len = aa.length > bb.length ? aa.length : bb.length;
  for (var i = 0; i < len; i++) {
    if (i >= aa.length) return -1;
    if (i >= bb.length) return 1;
    final c = aa[i].compareTo(bb[i]);
    if (c != 0) return c;
  }
  return 0;
}

List<int> _wbsSegments(String w) {
  return w
      .trim()
      .split('.')
      .map((s) => int.tryParse(s.trim()) ?? 0)
      .toList();
}

/// Canonical row order for grid + Gantt (must match between panes).
List<Task> orderTasksForGantt(List<Task> tasks) {
  final copy = List<Task>.from(tasks);
  copy.sort((x, y) => compareWbs(x.wbs, y.wbs));
  return copy;
}

/// Visual indent: whole-number WBS (`1`) → 0; `1.1` → 1; `1.1.1` → 2.
int ganttRowIndentDepth(Task task) {
  final w = task.wbs.trim();
  if (w.isEmpty) return 0;
  return w.split('.').length - 1;
}
