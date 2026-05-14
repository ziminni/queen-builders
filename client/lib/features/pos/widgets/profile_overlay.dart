import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/transaction.dart';
import 'store_cashier_details.dart';

class ProfileOverlay extends StatefulWidget {
  final String userName;
  final String userRole;
  final String userInitials;
  final VoidCallback? onLogout;
  final List<Transaction> transactions;

  const ProfileOverlay({
    super.key,
    required this.userName,
    required this.userRole,
    required this.userInitials,
    this.onLogout,
    this.transactions = const [],
  });

  @override
  State<ProfileOverlay> createState() => _ProfileOverlayState();

  static void show(
    BuildContext context, {
    required String userName,
    required String userRole,
    required String userInitials,
    VoidCallback? onLogout,
    List<Transaction> transactions = const [],
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Profile Overlay',
      barrierColor: Colors.black.withOpacity(0.25),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ProfileOverlay(
          userName: userName,
          userRole: userRole,
          userInitials: userInitials,
          onLogout: onLogout ?? () => Navigator.of(context).pop(),
          transactions: transactions,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _ProfileOverlayState extends State<ProfileOverlay> {
  bool _isArrowHovered = false;

  static String _shortTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.month}/${d.day} $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }

  Widget _buildContent() {
    final collectibles = widget.transactions.where((t) => t.isPayLater).toList();
    final collectibleTotal =
        collectibles.fold<double>(0, (sum, t) => sum + t.total);
    final recent = widget.transactions.take(12).toList();

    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 350,
            margin: const EdgeInsets.only(top: 78, right: 383),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              border: Border.all(color: AppColors.richGold.withOpacity(0.7), width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    color: AppColors.richGold,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF8F8F8),
                        ),
                        child: Center(
                          child: Text(
                            widget.userInitials,
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.richGold,
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.userName,
                              style: AppTextStyles.h3.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              widget.userRole,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                      MouseRegion(
                        onEnter: (_) => setState(() => _isArrowHovered = true),
                        onExit: (_) => setState(() => _isArrowHovered = false),
                        cursor: SystemMouseCursors.click,
                        child: InkWell(
                          onTap: () => _showStoreCashierDetails(context),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _isArrowHovered
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: _isArrowHovered
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.8),
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (collectibles.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    decoration: BoxDecoration(
                      color: AppColors.richGold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.richGold.withOpacity(0.35)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.handshake_outlined, color: AppColors.richGold, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Collectibles (utang)',
                                style: AppTextStyles.labelSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.deepBlack,
                                ),
                              ),
                              Text(
                                '${collectibles.length} record${collectibles.length == 1 ? '' : 's'} · ₱${collectibleTotal.toStringAsFixed(2)} total',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Recent Transactions',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.deepBlack,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.richGold,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => _AllTransactionsDialog.show(context, widget.transactions),
                        child: Text(
                          'See all',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.richGold,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(maxHeight: 320),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.border.withOpacity(0.8)),
                      bottom: BorderSide(color: AppColors.border.withOpacity(0.8)),
                    ),
                  ),
                  child: recent.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 40,
                                  color: AppColors.textSecondary.withOpacity(0.35),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No transactions yet',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary.withOpacity(0.85),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: recent.length,
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            color: AppColors.border.withOpacity(0.5),
                          ),
                          itemBuilder: (context, index) {
                            return _TransactionRow(
                              transaction: recent[index],
                              shortTime: _shortTime,
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: widget.onLogout,
                      icon: const Icon(Icons.logout, size: 20),
                      label: Text(
                        'Logout',
                        style: AppTextStyles.h4.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2C2A2D),
                        side: BorderSide(color: AppColors.border.withOpacity(0.95)),
                        backgroundColor: const Color(0xFFF3F3F3),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStoreCashierDetails(BuildContext context) {
    Navigator.of(context).pop();
    StoreCashierDetails.show(
      context,
      userName: widget.userName,
      userRole: widget.userRole,
      userInitials: widget.userInitials,
    );
  }
}

class _AllTransactionsDialog extends StatefulWidget {
  final List<Transaction> transactions;

  const _AllTransactionsDialog({required this.transactions});

  static void show(BuildContext context, List<Transaction> transactions) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _AllTransactionsDialog(transactions: transactions),
    );
  }

  @override
  State<_AllTransactionsDialog> createState() => _AllTransactionsDialogState();
}

enum _TxnScope { all, paid, collectible }

class _AllTransactionsDialogState extends State<_AllTransactionsDialog> {
  _TxnScope _scope = _TxnScope.all;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  static String _shortTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.month}/${d.day}/' '${d.year} $h:$m';
  }

  List<Transaction> get _sorted {
    final list = List<Transaction>.from(widget.transactions);
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  List<Transaction> get _scopeFiltered {
    final list = _sorted;
    switch (_scope) {
      case _TxnScope.all:
        return list;
      case _TxnScope.paid:
        return list.where((t) => !t.isPayLater).toList();
      case _TxnScope.collectible:
        return list.where((t) => t.isPayLater).toList();
    }
  }

  bool _matchesQuery(Transaction t, String raw) {
    final q = raw.trim().toLowerCase();
    if (q.isEmpty) return true;

    bool has(String? x) => x != null && x.toLowerCase().contains(q);

    if (t.id.toLowerCase().contains(q)) return true;
    if (has(t.customerName)) return true;
    if (has(t.customerPhone)) return true;
    if (has(t.customerAddress)) return true;
    if (has(t.paymentMethod)) return true;
    final totalStr = t.total.toStringAsFixed(2);
    if (totalStr.contains(q) || t.total.toString().contains(q)) return true;
    for (final i in t.items) {
      if (i.name.toLowerCase().contains(q)) return true;
    }
    return false;
  }

  List<Transaction> get _filtered {
    final q = _searchCtrl.text;
    final scoped = _scopeFiltered;
    if (q.trim().isEmpty) return scoped;
    return scoped.where((t) => _matchesQuery(t, q)).toList();
  }

  Widget _filterChip({required _TxnScope scope, required String label}) {
    final selected = _scope == scope;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _scope = scope),
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.richGold.withOpacity(0.18)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? AppColors.richGold : AppColors.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? AppColors.deepBlack : AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final mq = MediaQuery.sizeOf(context);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.richGold, width: 2),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: SizedBox(
        width: mq.width < 576 ? mq.width - 56 : 520,
        height: mq.height * 0.78,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'All transactions',
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepBlack,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: AppColors.textSecondary.withOpacity(0.9)),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Name, phone, ID, items, amount…',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      isDense: true,
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20,
                        color: AppColors.textSecondary.withOpacity(0.85),
                      ),
                      suffixIcon: _searchCtrl.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() {});
                              },
                              icon: Icon(
                                Icons.clear,
                                size: 20,
                                color: AppColors.textSecondary.withOpacity(0.85),
                              ),
                              tooltip: 'Clear',
                            ),
                      filled: true,
                      fillColor: const Color(0xFFF8F8F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.richGold, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Filter',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _filterChip(scope: _TxnScope.all, label: 'All'),
                      const SizedBox(width: 8),
                      _filterChip(scope: _TxnScope.paid, label: 'Paid'),
                      const SizedBox(width: 8),
                      _filterChip(scope: _TxnScope.collectible, label: 'Collectible'),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _searchCtrl.text.trim().isNotEmpty
                                  ? Icons.search_off_outlined
                                  : Icons.filter_list_off_outlined,
                              size: 44,
                              color: AppColors.textSecondary.withOpacity(0.4),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchCtrl.text.trim().isNotEmpty
                                  ? 'No matches for "${_searchCtrl.text.trim()}"'
                                  : _scope == _TxnScope.all
                                      ? 'No transactions yet'
                                      : _scope == _TxnScope.paid
                                          ? 'No paid sales in this list'
                                          : 'No collectibles in this list',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        color: AppColors.border.withOpacity(0.55),
                      ),
                      itemBuilder: (context, index) {
                        return _TransactionRow(
                          transaction: filtered[index],
                          shortTime: _shortTime,
                        );
                      },
                    ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                '${filtered.length} shown · ${widget.transactions.length} total in session',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final Transaction transaction;
  final String Function(DateTime) shortTime;

  const _TransactionRow({
    required this.transaction,
    required this.shortTime,
  });

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final name = (t.customerName != null && t.customerName!.isNotEmpty)
        ? t.customerName!
        : 'Walk-in';
    final extra = t.isPayLater && t.customerPhone != null && t.customerPhone!.isNotEmpty
        ? ' · ${t.customerPhone}'
        : (!t.isPayLater &&
                t.customerPhone != null &&
                t.customerPhone!.isNotEmpty)
            ? ' · ${t.customerPhone}'
            : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₱${t.total.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepBlack,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${shortTime(t.timestamp)} · $name$extra',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    decoration: TextDecoration.none,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (t.isPayLater &&
                    t.customerAddress != null &&
                    t.customerAddress!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    t.customerAddress!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: t.isPayLater
                            ? AppColors.richGold.withOpacity(0.2)
                            : AppColors.border.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        t.isPayLater ? 'Utang' : 'Cash',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: t.isPayLater ? AppColors.deepBlack : AppColors.textSecondary,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        t.paymentMethod,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.none,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

