import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/wbs_material_line.dart';
import '../models/work_breakdown_category.dart';
import '../viewmodel/project_detail_viewmodel.dart';
import 'metric_cards.dart';

/// Construction WBS & financial planning UI for the Project **Financials** tab.
class ProjectFinanceWbsPanel extends StatelessWidget {
  const ProjectFinanceWbsPanel({super.key});

  static const List<String> categoryPresets = [
    'Structure',
    'Roofing',
    'Flooring',
    'Plumbing',
    'Electrical',
    'Painting',
    'Others',
  ];

  static const List<String> statusOptions = [
    'Not Started',
    'Ongoing',
    'Completed',
  ];

  static const List<String> unitPresets = [
    'pcs',
    'bags',
    'meters',
    'kilograms',
    'liters',
    'sqm',
    'units',
  ];

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,##0', 'en_US');

    return Consumer<ProjectDetailViewModel>(
      builder: (context, vm, _) {
        final metrics = vm.calculateMetrics(vm.totalAllocatedBudget);
        final used =
            vm.entries.fold(0.0, (s, e) => s + e.actualCost) +
            vm.wbsTotalMaterialCost;
        final remaining = vm.totalAllocatedBudget - used;
        final utilization = vm.totalAllocatedBudget > 0
            ? (used / vm.totalAllocatedBudget * 100)
            : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (vm.hasBudgetOverrun)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.error,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Budget overrun: total used exceeds allocated project budget.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Financial summary
            LayoutBuilder(
              builder: (context, constraints) {
                final maxW = constraints.maxWidth;
                final cardWidth = maxW >= 1000
                    ? (maxW - 64) / 5
                    : maxW >= 640
                    ? (maxW - 48) / 3
                    : maxW - 32;

                Widget sizedMetric(Widget child) => SizedBox(
                  width: cardWidth.clamp(140.0, 280.0),
                  child: child,
                );

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.start,
                  children: [
                    sizedMetric(
                      MetricCard(
                        label: 'Total Allocated Budget',
                        value:
                            '₱${numberFormat.format(vm.totalAllocatedBudget)}',
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: AppColors.richGold,
                      ),
                    ),
                    sizedMetric(
                      MetricCard(
                        label: 'Total Used Budget',
                        value: '₱${numberFormat.format(used)}',
                        icon: Icons.payments_outlined,
                        iconColor: const Color(0xFFF59E0B),
                      ),
                    ),
                    sizedMetric(
                      MetricCard(
                        label: 'Remaining Budget',
                        value: '₱${numberFormat.format(remaining)}',
                        icon: Icons.savings_outlined,
                        iconColor: remaining < 0
                            ? AppColors.error
                            : AppColors.success,
                        valueColor: remaining < 0
                            ? AppColors.error
                            : AppColors.success,
                      ),
                    ),
                    sizedMetric(
                      Tooltip(
                        message:
                            'Progress % will be calculated later from planned vs actual costs.',
                        waitDuration: const Duration(milliseconds: 400),
                        child: ProgressMetricCard(
                          label: 'Overall Progress',
                          progress: metrics.progress,
                        ),
                      ),
                    ),
                    sizedMetric(
                      MetricCard(
                        label: 'Completed Categories',
                        value:
                            '${vm.completedWorkCategoriesCount} / ${vm.workCategories.length}',
                        icon: Icons.check_circle_outline,
                        iconColor: AppColors.success,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 8),
            Text(
              'Budget utilization: ${utilization.toStringAsFixed(1)}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            // Section header + actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Work Breakdown Structure & Materials',
                              style: AppTextStyles.h3.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Define work phases and line-item materials (planned quantities & costs).',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        onPressed: () => _showCategoryEditor(context, vm, null),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.richGold,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.add, size: 20),
                        label: Text(
                          'Add work category',
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: vm.setWbsSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Search categories…',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: const Color(0xFFFAFAFA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFFD9D9D9),
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFFD9D9D9),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (vm.filteredWorkCategories.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Center(
                  child: Text(
                    vm.workCategories.isEmpty
                        ? 'No work categories yet. Add Structure, Roofing, Plumbing, etc.'
                        : 'No categories match your search.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              ...vm.filteredWorkCategories.map(
                (cat) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _WbsCategoryCard(
                    category: cat,
                    numberFormat: numberFormat,
                    onEditCategory: () => _showCategoryEditor(context, vm, cat),
                    onDeleteCategory: () =>
                        _confirmDeleteCategory(context, vm, cat),
                    onAddMaterial: () =>
                        _showMaterialEditor(context, vm, cat.id, null),
                    onEditMaterial: (m) =>
                        _showMaterialEditor(context, vm, cat.id, m),
                    onDeleteMaterial: (m) => vm.removeMaterial(cat.id, m.id),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  static Color statusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppColors.success;
      case 'Ongoing':
        return const Color(0xFFF59E0B);
      default:
        return AppColors.textSecondary;
    }
  }

  static Future<void> _confirmDeleteCategory(
    BuildContext context,
    ProjectDetailViewModel vm,
    WorkBreakdownCategory cat,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete category'),
        content: Text('Remove "${cat.categoryName}" and all its materials?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok == true) vm.removeWorkCategory(cat.id);
  }

  static Future<void> _showCategoryEditor(
    BuildContext context,
    ProjectDetailViewModel vm,
    WorkBreakdownCategory? existing,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _CategoryEditorDialog(vm: vm, existing: existing),
    );
  }

  static Future<void> _showMaterialEditor(
    BuildContext context,
    ProjectDetailViewModel vm,
    int categoryId,
    WbsMaterialLine? existing,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _MaterialEditorDialog(
        vm: vm,
        categoryId: categoryId,
        existing: existing,
      ),
    );
  }
}

class _CategoryEditorDialog extends StatefulWidget {
  final ProjectDetailViewModel vm;
  final WorkBreakdownCategory? existing;

  const _CategoryEditorDialog({required this.vm, this.existing});

  @override
  State<_CategoryEditorDialog> createState() => _CategoryEditorDialogState();
}

class _CategoryEditorDialogState extends State<_CategoryEditorDialog> {
  late String _preset;
  late TextEditingController _customNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _budgetController;
  late String _status;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _preset = ProjectFinanceWbsPanel.categoryPresets.contains(e?.categoryName)
        ? e!.categoryName
        : 'Others';
    _customNameController = TextEditingController(
      text: _preset == 'Others' && e != null ? e.categoryName : '',
    );
    _descriptionController = TextEditingController(text: e?.description ?? '');
    _budgetController = TextEditingController(
      text: e != null && e.assignedBudget > 0
          ? e.assignedBudget.toString()
          : '',
    );
    _status = e?.status ?? 'Not Started';
  }

  @override
  void dispose() {
    _customNameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  String _resolvedName() {
    if (_preset == 'Others') {
      return _customNameController.text.trim().isEmpty
          ? 'Others'
          : _customNameController.text.trim();
    }
    return _preset;
  }

  void _submit() {
    final name = _resolvedName();
    final budget = double.tryParse(_budgetController.text) ?? 0;
    final desc = _descriptionController.text.trim();
    if (widget.existing == null) {
      widget.vm.addWorkCategory(
        widget.vm.newCategoryDraft(
          categoryName: name,
          description: desc.isEmpty ? null : desc,
          assignedBudget: budget,
          status: _status,
        ),
      );
    } else {
      widget.vm.updateWorkCategory(
        widget.existing!.copyWith(
          categoryName: name,
          description: desc.isEmpty ? null : desc,
          clearDescription: desc.isEmpty,
          assignedBudget: budget,
          progressPercentage: 0,
          status: _status,
        ),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existing == null ? 'Add work category' : 'Edit work category',
        style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w600),
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _preset,
                decoration: _dialogInputDecoration(),
                items: ProjectFinanceWbsPanel.categoryPresets
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _preset = v ?? 'Structure'),
              ),
              if (_preset == 'Others') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _customNameController,
                  decoration: _dialogInputDecoration(
                    hint: 'Custom category name',
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: _dialogInputDecoration(
                  hint: 'Description (optional)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _budgetController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                decoration: _dialogInputDecoration(hint: 'Assigned budget (₱)'),
              ),
              const SizedBox(height: 8),
              Text('Status', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: _dialogInputDecoration(),
                items: ProjectFinanceWbsPanel.statusOptions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v ?? 'Not Started'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: AppColors.richGold),
          child: const Text('Save'),
        ),
      ],
    );
  }

  InputDecoration _dialogInputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}

class _MaterialEditorDialog extends StatefulWidget {
  final ProjectDetailViewModel vm;
  final int categoryId;
  final WbsMaterialLine? existing;

  const _MaterialEditorDialog({
    required this.vm,
    required this.categoryId,
    this.existing,
  });

  @override
  State<_MaterialEditorDialog> createState() => _MaterialEditorDialogState();
}

class _MaterialEditorDialogState extends State<_MaterialEditorDialog> {
  late TextEditingController _nameController;
  late TextEditingController _qtyController;
  late TextEditingController _unitCostController;
  late TextEditingController _supplierController;
  late String _unit;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _qtyController = TextEditingController(
      text: e != null ? e.quantity.toString() : '1',
    );
    _unitCostController = TextEditingController(
      text: e != null ? e.unitCost.toString() : '',
    );
    _supplierController = TextEditingController(text: e?.supplier ?? '');
    _unit = e != null && ProjectFinanceWbsPanel.unitPresets.contains(e.unitType)
        ? e.unitType
        : ProjectFinanceWbsPanel.unitPresets.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _unitCostController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final qty = double.tryParse(_qtyController.text) ?? 0;
    final cost = double.tryParse(_unitCostController.text) ?? 0;
    final sup = _supplierController.text.trim();

    if (widget.existing == null) {
      widget.vm.addMaterial(
        widget.categoryId,
        widget.vm.newMaterialDraft(
          name: name,
          quantity: qty,
          unitType: _unit,
          unitCost: cost,
          supplier: sup.isEmpty ? null : sup,
        ),
      );
    } else {
      widget.vm.updateMaterial(
        widget.categoryId,
        widget.existing!.copyWith(
          name: name,
          quantity: qty,
          unitType: _unit,
          unitCost: cost,
          supplier: sup.isEmpty ? null : sup,
          clearSupplier: sup.isEmpty,
        ),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final qty = double.tryParse(_qtyController.text) ?? 0;
    final uc = double.tryParse(_unitCostController.text) ?? 0;
    final total = qty * uc;

    return AlertDialog(
      title: Text(
        widget.existing == null ? 'Add material' : 'Edit material',
        style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w600),
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Material name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _qtyController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _unit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                      items: ProjectFinanceWbsPanel.unitPresets
                          .map(
                            (u) => DropdownMenuItem(value: u, child: Text(u)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _unit = v ?? 'pcs'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _unitCostController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Unit cost (₱)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _supplierController,
                decoration: const InputDecoration(
                  labelText: 'Supplier (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Total cost: ₱${NumberFormat('#,##0.00', 'en_US').format(total)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: AppColors.richGold),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _WbsCategoryCard extends StatelessWidget {
  final WorkBreakdownCategory category;
  final NumberFormat numberFormat;
  final VoidCallback onEditCategory;
  final VoidCallback onDeleteCategory;
  final VoidCallback onAddMaterial;
  final void Function(WbsMaterialLine m) onEditMaterial;
  final void Function(WbsMaterialLine m) onDeleteMaterial;

  const _WbsCategoryCard({
    required this.category,
    required this.numberFormat,
    required this.onEditCategory,
    required this.onDeleteCategory,
    required this.onAddMaterial,
    required this.onEditMaterial,
    required this.onDeleteMaterial,
  });

  @override
  Widget build(BuildContext context) {
    final statusCol = ProjectFinanceWbsPanel.statusColor(category.status);
    final over = category.isOverBudget;

    return Material(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: over ? AppColors.error : const Color(0xFFE0E0E0),
          width: over ? 2 : 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: statusCol,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  category.categoryName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusCol.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  category.status,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: statusCol,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Assigned ₱${numberFormat.format(category.assignedBudget)} • '
                'Materials (planned) ₱${numberFormat.format(category.totalMaterialCost)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Completion % will update automatically once actual costs can be recorded.',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              if (over)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Over budget on this category',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
          children: [
            if ((category.description ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  category.description!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onEditCategory,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit category'),
                ),
                TextButton.icon(
                  onPressed: onDeleteCategory,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AppColors.error,
                  ),
                  label: Text(
                    'Delete',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Materials',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onAddMaterial,
                  icon: const Icon(
                    Icons.add,
                    size: 18,
                    color: AppColors.richGold,
                  ),
                  label: Text(
                    'Add material',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.richGold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (category.materials.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No materials yet',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xFFFAFAFA),
                  ),
                  columns: const [
                    DataColumn(label: Text('Material')),
                    DataColumn(label: Text('Qty')),
                    DataColumn(label: Text('Unit')),
                    DataColumn(label: Text('Unit cost')),
                    DataColumn(label: Text('Total')),
                    DataColumn(label: Text('Supplier')),
                    DataColumn(label: Text('')),
                  ],
                  rows: category.materials.map((m) {
                    return DataRow(
                      cells: [
                        DataCell(Text(m.name, style: AppTextStyles.bodySmall)),
                        DataCell(Text(m.quantity.toString())),
                        DataCell(Text(m.unitType)),
                        DataCell(Text('₱${numberFormat.format(m.unitCost)}')),
                        DataCell(Text('₱${numberFormat.format(m.lineTotal)}')),
                        DataCell(Text(m.supplier ?? '—')),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Edit',
                                onPressed: () => onEditMaterial(m),
                                icon: const Icon(Icons.edit_outlined, size: 18),
                              ),
                              IconButton(
                                tooltip: 'Delete',
                                onPressed: () => onDeleteMaterial(m),
                                icon: Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
