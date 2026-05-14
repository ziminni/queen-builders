import 'task.dart';

class GanttRow {
  final String id;
  final int rowNumber;
  final Task? task;

  GanttRow({
    required this.id,
    required this.rowNumber,
    this.task,
  });

  factory GanttRow.fromJson(Map<String, dynamic> json) {
    return GanttRow(
      id: json['id'],
      rowNumber: json['rowNumber'],
      task: json['task'] != null ? Task.fromJson(json['task']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rowNumber': rowNumber,
      'task': task?.toJson(),
    };
  }
}
