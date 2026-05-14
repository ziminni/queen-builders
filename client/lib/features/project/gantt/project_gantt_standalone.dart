import 'package:flutter/material.dart';
import 'package:legacy_gantt_chart/legacy_gantt_chart.dart';
import 'package:window_manager/window_manager.dart';

import '../../../core/constants/app_colors.dart';
import '../data/project_schedule_seed.dart';
import '../models/task.dart';
import '../utils/wbs_utils.dart';
import 'gantt_task_mapper.dart';

/// Second-engine entry: isolated MaterialApp for the full Gantt tool window.
class ProjectGanttStandaloneApp extends StatelessWidget {
  final int projectId;
  final String projectName;
  final List<Task> scheduleTasks;
  final String projectStartDate;
  final String projectDeadline;

  const ProjectGanttStandaloneApp({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.scheduleTasks,
    required this.projectStartDate,
    required this.projectDeadline,
  });

  @override
  Widget build(BuildContext context) {
    final title = projectName.isEmpty ? 'Project $projectId — Gantt' : '$projectName — Gantt';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.richGold),
        useMaterial3: true,
      ),
      home: ProjectGanttToolScreen(
        projectId: projectId,
        projectName: projectName,
        scheduleTasks: scheduleTasks,
        projectStartDate: projectStartDate,
        projectDeadline: projectDeadline,
      ),
    );
  }
}

/// Full-window Gantt workspace using legacy_gantt_chart (toolbar + chart).
class ProjectGanttToolScreen extends StatefulWidget {
  final int projectId;
  final String projectName;
  final List<Task> scheduleTasks;
  final String projectStartDate;
  final String projectDeadline;

  const ProjectGanttToolScreen({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.scheduleTasks,
    required this.projectStartDate,
    required this.projectDeadline,
  });

  @override
  State<ProjectGanttToolScreen> createState() => _ProjectGanttToolScreenState();
}

class _ProjectGanttToolScreenState extends State<ProjectGanttToolScreen> {
  static const double _timelineAxisHeight = 28;
  static const double _rowHeight = 36;
  static const double _scheduleGridWidth = 380;

  late final LegacyGanttController _controller;
  late final ScrollController _verticalScroll;
  late final ScrollController _horizontalScroll;
  late final List<LegacyGanttRow> _rows;
  late final Map<String, int> _rowDepth;

  /// Tasks driving the chart (VM snapshot or seeded).
  late final List<Task> _domainTasks;

  @override
  void initState() {
    super.initState();
    _verticalScroll = ScrollController();
    _horizontalScroll = ScrollController();

    _domainTasks = widget.scheduleTasks.isNotEmpty
        ? orderTasksForGantt(List<Task>.from(widget.scheduleTasks))
        : seedScheduleTasks(
            projectId: widget.projectId,
            projectStartDate: widget.projectStartDate,
            projectDeadline: widget.projectDeadline,
          );

    final legacyTasks = legacyGanttTasksFromTasks(_domainTasks);
    final deps = legacyDependenciesFromTasks(_domainTasks);
    _rows = legacyRowsForTasks(_domainTasks);
    _rowDepth = rowDepthForTasks(_domainTasks);

    final starts = legacyTasks.map((t) => t.start).toList()..sort();
    final ends = legacyTasks.map((t) => t.end).toList()..sort();
    final domainStart = starts.first.subtract(const Duration(days: 14));
    final domainEnd = ends.last.add(const Duration(days: 21));

    _controller = LegacyGanttController(
      initialVisibleStartDate: domainStart,
      initialVisibleEndDate: domainEnd,
      initialTasks: legacyTasks,
      initialDependencies: deps,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _verticalScroll.dispose();
    _horizontalScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final legacyTasks = _controller.tasks;
    final starts = legacyTasks.map((t) => t.start).toList();
    final ends = legacyTasks.map((t) => t.end).toList();
    final minStart = starts.reduce((a, b) => a.isBefore(b) ? a : b);
    final maxEnd = ends.reduce((a, b) => a.isAfter(b) ? a : b);
    final totalMin = minStart.subtract(const Duration(days: 7)).millisecondsSinceEpoch.toDouble();
    final totalMax = maxEnd.add(const Duration(days: 14)).millisecondsSinceEpoch.toDouble();

    final theme = LegacyGanttTheme.fromTheme(Theme.of(context));
    final subtitle = widget.projectName.isEmpty ? 'Project ID ${widget.projectId}' : widget.projectName;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Gantt chart'),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: AppColors.deepBlack,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Close window',
            icon: const Icon(Icons.close),
            onPressed: () => windowManager.close(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LegacyGanttToolbar(controller: _controller, theme: theme),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: _scheduleGridWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.backgroundColor,
                      border: Border(
                        right: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _GanttScheduleHeader(
                          height: _timelineAxisHeight,
                          textStyle: theme.axisTextStyle.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: _verticalScroll,
                            itemExtent: _rowHeight,
                            itemCount: _domainTasks.length,
                            itemBuilder: (context, index) {
                              final t = _domainTasks[index];
                              return _GanttScheduleRow(
                                index: index + 1,
                                task: t,
                                indentDepth: ganttRowIndentDepth(t),
                                rowHeight: _rowHeight,
                                bodyStyle: theme.axisTextStyle,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: LegacyGanttChartWidget(
                    controller: _controller,
                    visibleRows: _rows,
                    rowMaxStackDepth: _rowDepth,
                    rowHeight: _rowHeight,
                    axisHeight: _timelineAxisHeight,
                    theme: theme,
                    scrollController: _verticalScroll,
                    horizontalScrollController: _horizontalScroll,
                    totalGridMin: totalMin,
                    totalGridMax: totalMax,
                    enableDragAndDrop: true,
                    enableResize: true,
                    enableVerticalTaskDrag: true,
                    showCursors: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GanttScheduleHeader extends StatelessWidget {
  final double height;
  final TextStyle textStyle;

  const _GanttScheduleHeader({
    required this.height,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final divider = Theme.of(context).dividerColor;
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: divider)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text('#', style: textStyle, textAlign: TextAlign.center),
              ),
              Expanded(child: Text('Task', style: textStyle)),
              SizedBox(
                width: 88,
                child: Text('WBS', style: textStyle, textAlign: TextAlign.right),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GanttScheduleRow extends StatelessWidget {
  final int index;
  final Task task;
  final int indentDepth;
  final double rowHeight;
  final TextStyle bodyStyle;

  const _GanttScheduleRow({
    required this.index,
    required this.task,
    required this.indentDepth,
    required this.rowHeight,
    required this.bodyStyle,
  });

  @override
  Widget build(BuildContext context) {
    final divider = Theme.of(context).dividerColor.withValues(alpha: 0.35);
    final wbs = task.wbs.trim().isNotEmpty ? task.wbs : '—';
    final taskLabel =
        task.isSummary ? '${task.name} (${task.progress.clamp(0, 100)}%)' : task.name;

    return SizedBox(
      height: rowHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: divider))),
        child: Padding(
          padding: EdgeInsets.only(left: 8 + indentDepth * 18.0, right: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  '$index',
                  style: bodyStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  taskLabel,
                  style: bodyStyle.copyWith(
                    fontWeight: task.isSummary ? FontWeight.w700 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 88,
                child: Text(
                  wbs,
                  style: bodyStyle,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
