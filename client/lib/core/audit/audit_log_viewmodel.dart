import 'package:flutter/foundation.dart';

import '../network/api_config.dart';
import '../services/api_service.dart';
import 'audit_log_entry.dart';

/// Global in-app audit trail (demo: in-memory). Wire `record` from feature modules.
class AuditLogViewModel extends ChangeNotifier {
  AuditLogViewModel({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  static const String moduleInventory = 'Inventory';
  static const String modulePos = 'POS';
  static const String moduleProjects = 'Projects';
  static const String moduleAdmin = 'Admin';
  static const String moduleSystem = 'System';

  static const String categoryProductCatalog = 'Product catalog';
  static const String categoryReceiving = 'Receiving & stock';
  static const String categorySales = 'Sales';
  static const String categoryProject = 'Project workspace';
  static const String categoryUsers = 'User management';
  static const String categoryMovement = 'Movement logs';
  static const String categorySystem = 'System configuration';

  final List<AuditLogEntry> _entries = [];
  bool _isLoading = false;
  String? _loadError;

  List<AuditLogEntry> get entries => List.unmodifiable(_entries);
  bool get isLoading => _isLoading;
  String? get loadError => _loadError;

  Future<void> refreshFromServer() async {
    _isLoading = true;
    _loadError = null;
    notifyListeners();
    try {
      final r = await _api.dio.get(ApiConfig.adminAuditLogs);
      final list = r.data as List<dynamic>;
      _entries
        ..clear()
        ..addAll(
          list.map(
            (e) => AuditLogEntry.fromJson(Map<String, dynamic>.from(e as Map)),
          ),
        );
      _loadError = null;
    } catch (e) {
      _loadError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void record({
    required String module,
    required String category,
    required String summary,
    String? detail,
  }) {
    _entries.insert(
      0,
      AuditLogEntry(
        id: 'AUD-${DateTime.now().microsecondsSinceEpoch}',
        at: DateTime.now(),
        module: module,
        category: category,
        summary: summary,
        detail: detail,
      ),
    );
    notifyListeners();
  }

  /// Demo / maintenance — confirm in UI before calling.
  void clearAll() {
    _entries.clear();
    notifyListeners();
  }
}
