import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/cart_item.dart';
import 'pos_checkout_feedback.dart';

InputDecoration _fieldDec({String? label, String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.richGold, width: 2),
    ),
  );
}

/// Cashier confirmation: proceed as cash vs pay-later before finalizing sale.
Future<bool> showCheckoutIntentConfirmDialog(
  BuildContext context, {
  required bool isPayLater,
  required double total,
  required int lineCount,
}) async {
  final totalPhp = total.toStringAsFixed(2);
  final r = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    transitionDuration: posModalTransitionDuration,
    transitionBuilder: posModalTransitionBuilder,
    pageBuilder: (ctx, _, _) {
      return Center(
        child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.richGold, width: 2),
        ),
        title: Row(
          children: [
            Icon(
              isPayLater
                  ? Icons.receipt_long_outlined
                  : Icons.payments_outlined,
              color: AppColors.richGold,
              size: 26,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isPayLater
                    ? 'Proceed with pay-later (Utang)?'
                    : 'Proceed with cash payment?',
                style: AppTextStyles.h3.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPayLater
                  ? 'This will record the sale as a collectible (accounts receivable). '
                      'No cash is received now.'
                  : 'This will complete the sale as paid in cash. '
                      'Make sure the customer has paid before you continue.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.richGold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.richGold.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total: ₱$totalPhp',
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.richGold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$lineCount line(s) · ${isPayLater ? 'Collectible' : 'Cash'}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Go back',
              style: AppTextStyles.button.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.richGold,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(
              isPayLater
                  ? 'Yes, record collectible'
                  : 'Yes, proceed with cash',
              style: AppTextStyles.button.copyWith(color: Colors.white),
            ),
          ),
        ],
        ),
      );
    },
  );
  return r == true;
}

/// Checkout: order summary + customer details. [onConfirm.isPayLater] is true when
/// Utang is enabled (collectible / pay-later instead of cash).
Future<void> showCashCustomerDialog(
  BuildContext context, {
  required List<CartItem> cartItems,
  required double subtotal,
  required double tax,
  required double total,
  required Future<void> Function({
    required bool isPayLater,
    required String customerName,
    required String contactNumber,
    String? customerAddress,
  }) onConfirm,
}) async {
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: posModalTransitionDuration,
    transitionBuilder: posModalTransitionBuilder,
    pageBuilder: (ctx, _, _) => Center(
      child: _CashPaymentDialog(
        cartItems: cartItems,
        subtotal: subtotal,
        tax: tax,
        total: total,
        onConfirm: onConfirm,
      ),
    ),
  );
}

class _CashPaymentDialog extends StatefulWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final double tax;
  final double total;
  final Future<void> Function({
    required bool isPayLater,
    required String customerName,
    required String contactNumber,
    String? customerAddress,
  }) onConfirm;

  const _CashPaymentDialog({
    required this.cartItems,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.onConfirm,
  });

  @override
  State<_CashPaymentDialog> createState() => _CashPaymentDialogState();
}

class _CashPaymentDialogState extends State<_CashPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _payLater = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    final name = _nameCtrl.text.trim();
    final contact = _phoneCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final payLater = _payLater;

    final confirmed = await showCheckoutIntentConfirmDialog(
      context,
      isPayLater: payLater,
      total: widget.total,
      lineCount: widget.cartItems.length,
    );

    if (!mounted || !confirmed) return;

    Navigator.of(context).pop();
    await widget.onConfirm(
      isPayLater: payLater,
      customerName: name,
      contactNumber: contact,
      customerAddress: payLater ? address : null,
    );
  }

  Widget _buildCustomerForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer details',
            style: AppTextStyles.h4.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _payLater
                ? 'Collectible (utang): name, address, and contact are required.'
                : 'Cash sale: full name and contact number are required.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: _fieldDec(
              label: 'Full name',
              hint: 'As shown on receipt',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Enter customer name';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: _fieldDec(
              label: 'Contact number',
              hint: 'Mobile or landline',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Enter contact number';
              }
              final d = v.replaceAll(RegExp(r'\D'), '');
              if (d.length < 7) {
                return 'Enter a valid contact number';
              }
              return null;
            },
          ),
          if (_payLater) ...[
            const SizedBox(height: 14),
            TextFormField(
              controller: _addressCtrl,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: _fieldDec(
                label: 'Address',
                hint: 'Required for collectibles',
              ),
              validator: (v) {
                if (!_payLater) return null;
                if (v == null || v.trim().isEmpty) {
                  return 'Enter customer address';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 20),
          Material(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
            child: SwitchListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              title: Text(
                'Utang (pay later / collectible)',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                _payLater
                    ? 'This sale will be stored as accounts receivable, not paid in cash now.'
                    : 'Turn on to convert this checkout to a collectible instead of cash.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              value: _payLater,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.richGold,
              inactiveThumbColor: AppColors.textSecondary,
              inactiveTrackColor: AppColors.border,
              onChanged: (v) => setState(() {
                _payLater = v ?? false;
                if (!_payLater) {
                  _addressCtrl.clear();
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final wide = media.size.width >= 720;
    final maxW = media.size.width.clamp(0.0, 920.0);

    final summaryPanel = _OrderSummaryPanel(
      cartItems: widget.cartItems,
      subtotal: widget.subtotal,
      tax: widget.tax,
      total: widget.total,
      isPayLater: _payLater,
    );

    final customerPanel = _buildCustomerForm();

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.richGold, width: 2),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW > 0 ? maxW : 920),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.richGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _payLater
                          ? Icons.receipt_long_outlined
                          : Icons.payments_outlined,
                      color: AppColors.richGold,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _payLater ? 'Collectible (Utang)' : 'Cash payment',
                          style: AppTextStyles.h3.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _payLater
                              ? 'Sale will be logged as pay-later / accounts receivable.'
                              : 'Confirm the order and customer before checkout.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            wide
                ? SizedBox(
                    height: 440,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 11,
                          child: summaryPanel,
                        ),
                        const VerticalDivider(
                            width: 1, color: AppColors.border),
                        Expanded(
                          flex: 10,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(
                                20, 20, 24, 20),
                            child: customerPanel,
                          ),
                        ),
                      ],
                    ),
                  )
                : ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 640),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 260,
                            child: summaryPanel,
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: AppColors.border),
                          const SizedBox(height: 20),
                          customerPanel,
                        ],
                      ),
                    ),
                  ),
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.richGold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _payLater ? 'Record collectible' : 'Complete checkout',
                      style: AppTextStyles.button.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderSummaryPanel extends StatelessWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final double tax;
  final double total;
  final bool isPayLater;

  const _OrderSummaryPanel({
    required this.cartItems,
    required this.subtotal,
    required this.tax,
    required this.total,
    this.isPayLater = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F8F8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 18,
                  color: AppColors.richGold.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 8),
                Text(
                  'Materials in this sale',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                itemCount: cartItems.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 16, color: Color(0xFFE8E8E8)),
                itemBuilder: (context, i) {
                  final item = cartItems[i];
                  final line = item.subtotal;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (item.category.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                item.category,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '× ${item.quantity}',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '@ ₱${item.price.toStringAsFixed(2)}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₱${line.toStringAsFixed(2)}',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.richGold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Column(
              children: [
                _totLine('Subtotal', subtotal, false),
                const SizedBox(height: 6),
                _totLine('VAT (12%)', tax, false),
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 10),
                _totLine(isPayLater ? 'Total to collect' : 'Total due', total, true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _totLine(String label, double amount, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                )
              : AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
        ),
        Text(
          '₱${amount.toStringAsFixed(2)}',
          style: isTotal
              ? AppTextStyles.h3.copyWith(
                  color: AppColors.richGold,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                )
              : AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                ),
        ),
      ],
    );
  }
}

/// Pay-later / collectible ("utang") — name, address, and contact are required.
Future<void> showPayLaterCustomerDialog(
  BuildContext context, {
  required double orderTotal,
  required int lineCount,
  required Future<void> Function({
    required String name,
    required String address,
    required String contact,
  }) onConfirm,
}) async {
  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final contactCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  await showGeneralDialog<void>(
    context: context,
    transitionDuration: posModalTransitionDuration,
    transitionBuilder: posModalTransitionBuilder,
    pageBuilder: (ctx, _, _) {
      return Center(
        child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.richGold, width: 2),
        ),
        title: Text(
          'Pay-Later (Utang)',
          style: AppTextStyles.h3.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer details are required for collectibles.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameCtrl,
                  decoration: _fieldDec(label: 'Full name', hint: 'Required'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter customer name';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressCtrl,
                  maxLines: 2,
                  decoration: _fieldDec(label: 'Address', hint: 'Required'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter address';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: contactCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: _fieldDec(label: 'Contact number', hint: 'Required'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter contact number';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTextStyles.button.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() != true) return;
              final ok = await showCheckoutIntentConfirmDialog(
                ctx,
                isPayLater: true,
                total: orderTotal,
                lineCount: lineCount,
              );
              if (ok != true) return;
              Navigator.pop(ctx);
              await onConfirm(
                name: nameCtrl.text.trim(),
                address: addressCtrl.text.trim(),
                contact: contactCtrl.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.richGold,
              foregroundColor: Colors.white,
            ),
            child: Text('Checkout', style: AppTextStyles.button),
          ),
        ],
        ),
      );
    },
  );
}
