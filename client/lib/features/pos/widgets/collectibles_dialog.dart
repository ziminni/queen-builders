import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/transaction.dart';

class CollectiblesDialog extends StatefulWidget {
  final List<Transaction> pending;
  final List<Transaction> paid;
  final Future<Transaction> Function(Transaction transaction) onMarkPaid;

  const CollectiblesDialog({
    super.key,
    required this.pending,
    required this.paid,
    required this.onMarkPaid,
  });

  static Future<void> show(
    BuildContext context, {
    required List<Transaction> pending,
    required List<Transaction> paid,
    required Future<Transaction> Function(Transaction transaction) onMarkPaid,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => CollectiblesDialog(
        pending: pending,
        paid: paid,
        onMarkPaid: onMarkPaid,
      ),
    );
  }

  @override
  State<CollectiblesDialog> createState() => _CollectiblesDialogState();
}

class _CollectiblesDialogState extends State<CollectiblesDialog> {
  final TextEditingController _searchCtrl = TextEditingController();
  late List<Transaction> _pending;
  late List<Transaction> _paid;
  bool _showPaidHistory = false;
  String? _updatingId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pending = List<Transaction>.from(widget.pending);
    _paid = List<Transaction>.from(widget.paid);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Transaction> get _source => _showPaidHistory ? _paid : _pending;

  List<Transaction> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    final list = List<Transaction>.from(_source)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (q.isEmpty) return list;
    return list.where((t) {
      bool has(String? value) =>
          value != null && value.toLowerCase().contains(q);
      return t.id.toLowerCase().contains(q) ||
          has(t.customerName) ||
          has(t.customerPhone) ||
          has(t.customerAddress) ||
          t.total.toStringAsFixed(2).contains(q) ||
          t.items.any((item) => item.name.toLowerCase().contains(q));
    }).toList();
  }

  double get _total =>
      _source.fold<double>(0, (sum, transaction) => sum + transaction.total);

  static String _dateTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.month}/${value.day}/${value.year} $hour:$minute';
  }

  Future<void> _markPaid(Transaction transaction) async {
    setState(() {
      _updatingId = transaction.id;
      _error = null;
    });
    try {
      final updated = await widget.onMarkPaid(transaction);
      if (!mounted) return;
      setState(() {
        _pending.removeWhere((item) => item.id == transaction.id);
        _paid.removeWhere((item) => item.id == transaction.id);
        _paid.insert(0, updated);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _updatingId = null);
      }
    }
  }

  void _showDetails(Transaction transaction) {
    CollectibleDetailsDialog.show(
      context,
      transaction: transaction,
      dateTime: _dateTime,
      paidHistory: _showPaidHistory,
      updating: _updatingId == transaction.id,
      onMarkPaid: () => _markPaid(transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final filtered = _filtered;
    final title = _showPaidHistory
        ? 'Paid collectibles'
        : 'Pending collectibles';

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.richGold, width: 2),
      ),
      child: SizedBox(
        width: size.width < 680 ? size.width - 56 : 620,
        height: size.height * 0.78,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.richGold.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.request_quote_outlined,
                      color: AppColors.richGold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.deepBlack,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_source.length} record${_source.length == 1 ? '' : 's'} · ₱${_total.toStringAsFixed(2)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tooltip(
                    message: _showPaidHistory
                        ? 'Show pending collectibles'
                        : 'Show paid collectibles',
                    child: IconButton(
                      onPressed: () => setState(() {
                        _showPaidHistory = !_showPaidHistory;
                        _error = null;
                      }),
                      icon: Icon(
                        _showPaidHistory
                            ? Icons.pending_actions_outlined
                            : Icons.history,
                      ),
                      color: _showPaidHistory
                          ? AppColors.richGold
                          : AppColors.textSecondary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.textSecondary.withValues(alpha: 0.9),
                    ),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search name, phone, ID, item, amount...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: AppColors.textSecondary.withValues(alpha: 0.85),
                  ),
                  suffixIcon: _searchCtrl.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear, size: 20),
                          tooltip: 'Clear',
                        ),
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.richGold,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Text(
                    _error!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.red.shade800,
                    ),
                  ),
                ),
              ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyCollectiblesState(
                      searching: _searchCtrl.text.trim().isNotEmpty,
                      paidHistory: _showPaidHistory,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final transaction = filtered[index];
                        return _CollectibleRow(
                          transaction: transaction,
                          dateTime: _dateTime,
                          paidHistory: _showPaidHistory,
                          updating: _updatingId == transaction.id,
                          onTap: () => _showDetails(transaction),
                          onMarkPaid: () => _markPaid(transaction),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectibleRow extends StatelessWidget {
  final Transaction transaction;
  final String Function(DateTime value) dateTime;
  final bool paidHistory;
  final bool updating;
  final VoidCallback onTap;
  final VoidCallback onMarkPaid;

  const _CollectibleRow({
    required this.transaction,
    required this.dateTime,
    required this.paidHistory,
    required this.updating,
    required this.onTap,
    required this.onMarkPaid,
  });

  @override
  Widget build(BuildContext context) {
    final name = (transaction.customerName ?? '').trim().isEmpty
        ? 'Walk-in'
        : transaction.customerName!.trim();
    final itemSummary = transaction.items
        .map((item) => '${item.name} x${item.quantity}')
        .join(', ');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: paidHistory
                  ? Colors.green.withValues(alpha: 0.26)
                  : AppColors.richGold.withValues(alpha: 0.34),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: paidHistory
                      ? Colors.green.withValues(alpha: 0.11)
                      : AppColors.richGold.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  paidHistory
                      ? Icons.check_circle_outline
                      : Icons.pending_actions_outlined,
                  color: paidHistory
                      ? Colors.green.shade700
                      : AppColors.richGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.deepBlack,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '₱${transaction.total.toStringAsFixed(2)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.deepBlack,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${transaction.id} · ${dateTime(transaction.timestamp)}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.65,
                          ),
                          size: 18,
                        ),
                      ],
                    ),
                    if ((transaction.customerPhone ?? '').trim().isNotEmpty ||
                        (transaction.customerAddress ?? '')
                            .trim()
                            .isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        [
                          if ((transaction.customerPhone ?? '')
                              .trim()
                              .isNotEmpty)
                            transaction.customerPhone!.trim(),
                          if ((transaction.customerAddress ?? '')
                              .trim()
                              .isNotEmpty)
                            transaction.customerAddress!.trim(),
                        ].join(' · '),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (itemSummary.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        itemSummary,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (paidHistory && transaction.paidAt != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 14,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Paid ${dateTime(transaction.paidAt!)}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (!paidHistory) ...[
                const SizedBox(width: 14),
                ElevatedButton.icon(
                  onPressed: updating ? null : onMarkPaid,
                  icon: updating
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.payments_outlined, size: 16),
                  label: const Text('Paid'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.richGold,
                    foregroundColor: AppColors.deepBlack,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CollectibleDetailsDialog extends StatelessWidget {
  final Transaction transaction;
  final String Function(DateTime value) dateTime;
  final bool paidHistory;
  final bool updating;
  final VoidCallback onMarkPaid;

  const CollectibleDetailsDialog({
    super.key,
    required this.transaction,
    required this.dateTime,
    required this.paidHistory,
    required this.updating,
    required this.onMarkPaid,
  });

  static Future<void> show(
    BuildContext context, {
    required Transaction transaction,
    required String Function(DateTime value) dateTime,
    required bool paidHistory,
    required bool updating,
    required VoidCallback onMarkPaid,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => CollectibleDetailsDialog(
        transaction: transaction,
        dateTime: dateTime,
        paidHistory: paidHistory,
        updating: updating,
        onMarkPaid: onMarkPaid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = (transaction.customerName ?? '').trim().isEmpty
        ? 'Walk-in'
        : transaction.customerName!.trim();
    final status = transaction.isCollectiblePaid ? 'Paid' : 'Pending';

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.richGold, width: 2),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.richGold.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: AppColors.richGold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.deepBlack,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${transaction.id} · $status collectible',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.textSecondary.withValues(alpha: 0.9),
                    ),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _detailTile(
                            icon: Icons.payments_outlined,
                            label: 'Amount due',
                            value: '₱${transaction.total.toStringAsFixed(2)}',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _detailTile(
                            icon: transaction.isCollectiblePaid
                                ? Icons.check_circle_outline
                                : Icons.pending_actions_outlined,
                            label: 'Status',
                            value: status,
                            accent: transaction.isCollectiblePaid
                                ? Colors.green.shade700
                                : AppColors.richGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _detailRow('Recorded', dateTime(transaction.timestamp)),
                    if (transaction.paidAt != null)
                      _detailRow('Paid date', dateTime(transaction.paidAt!)),
                    _detailRow('Payment method', transaction.paymentMethod),
                    _detailRow('Customer', name),
                    if ((transaction.customerPhone ?? '').trim().isNotEmpty)
                      _detailRow('Contact', transaction.customerPhone!.trim()),
                    if ((transaction.customerAddress ?? '').trim().isNotEmpty)
                      _detailRow(
                        'Address',
                        transaction.customerAddress!.trim(),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'Items',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          for (
                            var i = 0;
                            i < transaction.items.length;
                            i++
                          ) ...[
                            if (i > 0)
                              const Divider(height: 1, color: AppColors.border),
                            _itemRow(transaction.items[i]),
                          ],
                          if (transaction.items.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Text(
                                'No item details available',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!transaction.isCollectiblePaid)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: updating
                        ? null
                        : () {
                            onMarkPaid();
                            Navigator.of(context).pop();
                          },
                    icon: updating
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.payments_outlined, size: 18),
                    label: const Text('Mark as paid'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.richGold,
                      foregroundColor: AppColors.deepBlack,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            if (transaction.isCollectiblePaid)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showReceiptPreview(context),
                    icon: const Icon(Icons.print_outlined, size: 18),
                    label: const Text('Print receipt'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.richGold,
                      foregroundColor: AppColors.deepBlack,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showReceiptPreview(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) =>
          _ReceiptPreviewDialog(transaction: transaction, dateTime: dateTime),
    );
  }

  Widget _detailTile({
    required IconData icon,
    required String label,
    required String value,
    Color? accent,
  }) {
    final color = accent ?? AppColors.deepBlack;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.deepBlack,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(TransactionItem item) {
    final lineTotal = item.price * item.quantity;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.name,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.deepBlack,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${item.quantity} x ₱${item.price.toStringAsFixed(2)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '₱${lineTotal.toStringAsFixed(2)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.deepBlack,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptPreviewDialog extends StatelessWidget {
  final Transaction transaction;
  final String Function(DateTime value) dateTime;

  const _ReceiptPreviewDialog({
    required this.transaction,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    final name = (transaction.customerName ?? '').trim().isEmpty
        ? 'Walk-in'
        : transaction.customerName!.trim();

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.richGold, width: 2),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Receipt preview',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.deepBlack,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBFBFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'QUEEN BUILDERS',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.deepBlack,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'POS Collectible Receipt',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Divider(height: 26, color: AppColors.border),
                    _receiptLine('Receipt no.', transaction.id),
                    _receiptLine('Customer', name),
                    _receiptLine('Recorded', dateTime(transaction.timestamp)),
                    if (transaction.paidAt != null)
                      _receiptLine('Paid', dateTime(transaction.paidAt!)),
                    if ((transaction.customerPhone ?? '').trim().isNotEmpty)
                      _receiptLine(
                        'Contact',
                        transaction.customerPhone!.trim(),
                      ),
                    const Divider(height: 26, color: AppColors.border),
                    for (final item in transaction.items) _receiptItem(item),
                    const Divider(height: 26, color: AppColors.border),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'TOTAL PAID',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.deepBlack,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          '₱${transaction.total.toStringAsFixed(2)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.deepBlack,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () => _showPrintingDialog(context),
                icon: const Icon(Icons.print_outlined, size: 18),
                label: const Text('Print receipt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.richGold,
                  foregroundColor: AppColors.deepBlack,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrintingDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PrintingReceiptDialog(transaction: transaction),
    );
  }

  Widget _receiptLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.deepBlack,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiptItem(TransactionItem item) {
    final lineTotal = item.price * item.quantity;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              '${item.name}\n${item.quantity} x ₱${item.price.toStringAsFixed(2)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.deepBlack,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '₱${lineTotal.toStringAsFixed(2)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.deepBlack,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrintingReceiptDialog extends StatefulWidget {
  final Transaction transaction;

  const _PrintingReceiptDialog({required this.transaction});

  @override
  State<_PrintingReceiptDialog> createState() => _PrintingReceiptDialogState();
}

class _PrintingReceiptDialogState extends State<_PrintingReceiptDialog> {
  double _progress = 0.18;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _runPrintSequence();
  }

  Future<void> _runPrintSequence() async {
    await Future<void>.delayed(const Duration(milliseconds: 360));
    if (!mounted) return;
    setState(() => _progress = 0.52);

    await Future<void>.delayed(const Duration(milliseconds: 520));
    if (!mounted) return;
    setState(() => _progress = 0.82);

    await Future<void>.delayed(const Duration(milliseconds: 520));
    if (!mounted) return;
    setState(() {
      _progress = 1;
      _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 36, vertical: 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.richGold, width: 2),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PrinterAnimation(done: _done),
              const SizedBox(height: 18),
              Text(
                _done ? 'Receipt printed' : 'Printing receipt...',
                textAlign: TextAlign.center,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.deepBlack,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _done
                    ? '${widget.transaction.id} is ready for release.'
                    : 'Preparing ${widget.transaction.id} for the cashier printer.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 7,
                  backgroundColor: AppColors.border.withValues(alpha: 0.55),
                  color: _done ? Colors.green.shade600 : AppColors.richGold,
                ),
              ),
              const SizedBox(height: 18),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _done
                    ? ElevatedButton.icon(
                        key: const ValueKey('done'),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Done'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.richGold,
                          foregroundColor: AppColors.deepBlack,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )
                    : OutlinedButton.icon(
                        key: const ValueKey('printing'),
                        onPressed: null,
                        icon: const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        label: const Text('Please wait'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrinterAnimation extends StatelessWidget {
  final bool done;

  const _PrinterAnimation({required this.done});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 118,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 520),
            curve: Curves.easeOutCubic,
            top: done ? 58 : 40,
            child: Container(
              width: 124,
              height: 58,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(height: 4, color: AppColors.border),
                  const SizedBox(height: 7),
                  Container(height: 4, color: AppColors.border),
                  const SizedBox(height: 7),
                  Container(
                    height: 4,
                    width: 70,
                    color: AppColors.richGold.withValues(alpha: 0.45),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            child: Container(
              width: 156,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.deepBlack,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.richGold, width: 2),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 104,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.richGold,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(9),
                      ),
                    ),
                    child: Icon(
                      done ? Icons.check_circle_outline : Icons.print_outlined,
                      color: AppColors.deepBlack,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCollectiblesState extends StatelessWidget {
  final bool searching;
  final bool paidHistory;

  const _EmptyCollectiblesState({
    required this.searching,
    required this.paidHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              searching
                  ? Icons.search_off_outlined
                  : paidHistory
                  ? Icons.history_toggle_off_outlined
                  : Icons.task_alt_outlined,
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              searching
                  ? 'No collectibles match your search'
                  : paidHistory
                  ? 'No paid collectibles yet'
                  : 'No pending collectibles',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
