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
}
