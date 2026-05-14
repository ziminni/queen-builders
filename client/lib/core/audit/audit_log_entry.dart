import 'package:flutter/foundation.dart';

/// Single audit row shown in Admin → Audit logs and fed by inventory, POS, etc.
@immutable
class AuditLogEntry {
  final String id;
  final DateTime at;
  /// High-level area, e.g. [AuditLogViewModel.moduleInventory].
  final String module;
  /// Sub-area within the module, e.g. "Product catalog", "Receiving & stock".
  final String category;
  final String summary;
  final String? detail;

  const AuditLogEntry({
    required this.id,
    required this.at,
    required this.module,
    required this.category,
    required this.summary,
    this.detail,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    final detail = (json['detail'] as String? ?? '').trim();
    final actorEmail = (json['actor_email'] as String? ?? '').trim();
    final actorRole = (json['actor_role'] as String? ?? '').trim();
    final actorLines = [
      if (actorEmail.isNotEmpty) 'Actor: $actorEmail',
      if (actorRole.isNotEmpty) 'Actor role: $actorRole',
    ];

    return AuditLogEntry(
      id: 'AUD-SERVER-${json['id']}',
      at: DateTime.parse(json['at'] as String).toLocal(),
      module: json['module'] as String? ?? 'System',
      category: json['category'] as String? ?? 'System configuration',
      summary: json['summary'] as String? ?? 'Audit event',
      detail: [
        if (detail.isNotEmpty) detail,
        if (actorLines.isNotEmpty) actorLines.join('\n'),
      ].join('\n\n'),
    );
  }
}
