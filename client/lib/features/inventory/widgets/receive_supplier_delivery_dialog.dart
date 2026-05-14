import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/scroll/desktop_smooth_scroll.dart';
import '../../../data/models/product.dart';
import '../../../data/models/supplier.dart';
import '../models/supplier_delivery_item.dart';
import 'receive_delivery_product_picker_dialog.dart';

class ReceiveSupplierDeliveryDialog extends StatefulWidget {
  final List<Product> products;
  final Future<void> Function(
    String supplierName,
    String supplierCode,
    String invoiceNumber,
    String date,
    String receivedBy,
    String notes,
    String warehouseLocation,
    List<SupplierDeliveryItem> items,
  ) onConfirm;

  const ReceiveSupplierDeliveryDialog({
    super.key,
    required this.products,
    required this.onConfirm,
  });

  @override
  State<ReceiveSupplierDeliveryDialog> createState() =>
      _ReceiveSupplierDeliveryDialogState();
}

class _ReceiveSupplierDeliveryDialogState
    extends State<ReceiveSupplierDeliveryDialog> {
  Supplier? _selectedSupplier;
  final FocusNode _supplierDropdownFocus = FocusNode();
  bool _supplierDropdownFocused = false;
  final TextEditingController _invoiceController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _receivedByController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  List<SupplierDeliveryItem> _deliveryItems = [
    SupplierDeliveryItem(productId: 0, quantity: 0)
  ];

  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, bool> _isFocused = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Set today's date
    final now = DateTime.now();
    _dateController.text = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Initialize focus nodes
    _focusNodes['invoice'] = FocusNode();
    _focusNodes['date'] = FocusNode();
    _focusNodes['receivedBy'] = FocusNode();
    _focusNodes['notes'] = FocusNode();
    _focusNodes['location'] = FocusNode();

    _supplierDropdownFocus.addListener(() {
      setState(() {
        _supplierDropdownFocused = _supplierDropdownFocus.hasFocus;
      });
    });

    // Add listeners for focus changes
    _focusNodes.forEach((key, node) {
      node.addListener(() {
        setState(() {
          _isFocused[key] = node.hasFocus;
        });
      });
    });
  }

  @override
  void dispose() {
    _supplierDropdownFocus.dispose();
    _invoiceController.dispose();
    _dateController.dispose();
    _receivedByController.dispose();
    _notesController.dispose();
    _locationController.dispose();
    _scrollController.dispose();
    _focusNodes.forEach((_, node) => node.dispose());
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // Validation
    if (_selectedSupplier == null) {
      _showAlert('Please select a supplier from the directory');
      return;
    }

    if (_invoiceController.text.trim().isEmpty) {
      _showAlert('Please enter invoice/DR number');
      return;
    }

    if (_receivedByController.text.trim().isEmpty) {
      _showAlert('Please enter who received the delivery');
      return;
    }

    final validItems = _deliveryItems
        .where((item) => item.productId > 0 && item.quantity > 0)
        .toList();

    if (validItems.isEmpty) {
      _showAlert('Please add at least one product with quantity');
      return;
    }

    try {
      await widget.onConfirm(
        _selectedSupplier!.name,
        _selectedSupplier!.code,
        _invoiceController.text,
        _dateController.text,
        _receivedByController.text,
        _notesController.text,
        _locationController.text,
        validItems,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        _showAlert(
            'Could not record the delivery. Check that the server is running and try again.');
      }
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final kb = media.viewInsets.bottom;
    final safeW = media.size.width - media.padding.horizontal - 32;
    final safeH = media.size.height - media.padding.vertical - kb - 40;
    final maxW = safeW.clamp(280.0, 672.0);
    final maxH = safeH.clamp(240.0, (media.size.height - kb) * 0.92);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.richGold, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final narrow = constraints.maxWidth < 520;
                    final pad = narrow ? 20.0 : 32.0;
                    final gap = narrow ? 12.0 : 16.0;

                    return ScrollConfiguration(
                      behavior: const DesktopSmoothScrollBehavior(),
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        thickness: 8,
                        radius: const Radius.circular(8),
                        interactive: true,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          primary: false,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.manual,
                          padding: EdgeInsets.fromLTRB(pad, pad, pad, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  'Receive Supplier Delivery',
                                  style: AppTextStyles.h2.copyWith(
                                    fontFamily: AppTextStyles.cinzelFont,
                                    color: AppColors.deepBlack,
                                    fontWeight: FontWeight.w600,
                                    fontSize: narrow ? 20 : null,
                                  ),
                                ),
                              ),
                              _CloseButton(
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                          SizedBox(height: narrow ? 16 : 24),
                          Container(
                            padding: EdgeInsets.all(narrow ? 12 : 16),
                            decoration: BoxDecoration(
                              color: AppColors.richGold.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFFD9D9D9), width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delivery Information',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.deepBlack,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: gap),
                                if (narrow) ...[
                                  _SupplierDropdownField(
                                    selected: _selectedSupplier,
                                    focusNode: _supplierDropdownFocus,
                                    isFocused: _supplierDropdownFocused,
                                    onChanged: (s) =>
                                        setState(() => _selectedSupplier = s),
                                  ),
                                  SizedBox(height: gap),
                                  _InputField(
                                    label: 'Invoice/DR Number',
                                    controller: _invoiceController,
                                    focusNode: _focusNodes['invoice']!,
                                    isFocused: _isFocused['invoice'] ?? false,
                                    placeholder:
                                        'Enter invoice or DR number',
                                    isRequired: true,
                                  ),
                                ] else
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _SupplierDropdownField(
                                          selected: _selectedSupplier,
                                          focusNode: _supplierDropdownFocus,
                                          isFocused: _supplierDropdownFocused,
                                          onChanged: (s) => setState(
                                            () => _selectedSupplier = s,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: gap),
                                      Expanded(
                                        child: _InputField(
                                          label: 'Invoice/DR Number',
                                          controller: _invoiceController,
                                          focusNode: _focusNodes['invoice']!,
                                          isFocused: _isFocused['invoice'] ??
                                              false,
                                          placeholder:
                                              'Enter invoice or DR number',
                                          isRequired: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                SizedBox(height: gap),
                                if (narrow) ...[
                                  _DateField(
                                    label: 'Delivery Date',
                                    controller: _dateController,
                                    focusNode: _focusNodes['date']!,
                                    isFocused: _isFocused['date'] ?? false,
                                    isRequired: true,
                                  ),
                                  SizedBox(height: gap),
                                  _InputField(
                                    label: 'Received By',
                                    controller: _receivedByController,
                                    focusNode: _focusNodes['receivedBy']!,
                                    isFocused:
                                        _isFocused['receivedBy'] ?? false,
                                    placeholder:
                                        'Name of person receiving',
                                    isRequired: true,
                                  ),
                                ] else
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _DateField(
                                          label: 'Delivery Date',
                                          controller: _dateController,
                                          focusNode: _focusNodes['date']!,
                                          isFocused:
                                              _isFocused['date'] ?? false,
                                          isRequired: true,
                                        ),
                                      ),
                                      SizedBox(width: gap),
                                      Expanded(
                                        child: _InputField(
                                          label: 'Received By',
                                          controller:
                                              _receivedByController,
                                          focusNode:
                                              _focusNodes['receivedBy']!,
                                          isFocused:
                                              _isFocused['receivedBy'] ??
                                                  false,
                                          placeholder:
                                              'Name of person receiving',
                                          isRequired: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                SizedBox(height: gap),
                                _TextAreaField(
                                  label: 'Notes/Remarks',
                                  controller: _notesController,
                                  focusNode: _focusNodes['notes']!,
                                  isFocused: _isFocused['notes'] ?? false,
                                  placeholder:
                                      'Any additional notes about this delivery',
                                  isRequired: false,
                                ),
                                SizedBox(height: gap),
                                _InputField(
                                  label: 'Warehouse location',
                                  controller: _locationController,
                                  focusNode: _focusNodes['location']!,
                                  isFocused:
                                      _isFocused['location'] ?? false,
                                  placeholder:
                                      'e.g., Aisle 1-A, Warehouse Zone B',
                                  isRequired: false,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: narrow ? 16 : 24),
                          Text(
                            'Products Received',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.deepBlack,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._deliveryItems.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ProductRow(
                                item: item,
                                products: widget.products,
                                maxWidth: constraints.maxWidth,
                                onProductChanged: (productId) {
                                  setState(() {
                                    _deliveryItems[index].productId =
                                        productId;
                                  });
                                },
                                onQuantityChanged: (quantity) {
                                  setState(() {
                                    _deliveryItems[index].quantity =
                                        quantity;
                                  });
                                },
                                showRemoveButton:
                                    _deliveryItems.length > 1,
                                onRemove: () {
                                  setState(() {
                                    _deliveryItems.removeAt(index);
                                  });
                                },
                              ),
                            );
                          }),
                          _AddProductButton(
                            onPressed: () {
                              setState(() {
                                _deliveryItems.add(
                                  SupplierDeliveryItem(
                                      productId: 0, quantity: 0),
                                );
                              });
                            },
                          ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              LayoutBuilder(
                builder: (context, c) {
                  final stackButtons = c.maxWidth < 380;
                  final hp = c.maxWidth < 520 ? 20.0 : 32.0;
                  return Material(
                    color: Colors.white,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(hp, 16, hp, 16),
                        child: stackButtons
                            ? Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  _CancelButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  const SizedBox(height: 12),
                                  _ConfirmButton(
                                    onPressed: _handleSubmit,
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: _CancelButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _ConfirmButton(
                                      onPressed: _handleSubmit,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Supplier picker — options match [Suppliers.all] (Suppliers page directory).
class _SupplierDropdownField extends StatelessWidget {
  final Supplier? selected;
  final FocusNode focusNode;
  final bool isFocused;
  final ValueChanged<Supplier?> onChanged;

  const _SupplierDropdownField({
    required this.selected,
    required this.focusNode,
    required this.isFocused,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Supplier',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.deepBlack,
              fontWeight: FontWeight.w500,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isFocused ? AppColors.richGold : const Color(0xFFD9D9D9),
              width: 2,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.richGold.withValues(alpha: 0.1),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Supplier>(
              value: selected,
              isExpanded: true,
              focusNode: focusNode,
              menuMaxHeight: 320,
              hint: Text(
                'Select from supplier directory',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              style: AppTextStyles.bodyMedium,
              icon: const Icon(Icons.keyboard_arrow_down, size: 22),
              items: Suppliers.all.map((s) {
                return DropdownMenuItem<Supplier>(
                  value: s,
                  child: Text(
                    '${s.name} (${s.code})',
                    style: AppTextStyles.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              selectedItemBuilder: (context) {
                return Suppliers.all.map((s) {
                  return Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: Text(
                        '${s.name} (${s.code})',
                        style: AppTextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList();
              },
              onChanged: onChanged,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            'Same list as Inventory → Suppliers',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

// Input Field Widget
class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final String placeholder;
  final bool isRequired;

  const _InputField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.placeholder,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.deepBlack,
              fontWeight: FontWeight.w500,
            ),
            children: isRequired
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isFocused ? AppColors.richGold : const Color(0xFFD9D9D9),
              width: 2,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.richGold.withOpacity(0.1),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

// Date Field Widget
class _DateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final bool isRequired;

  const _DateField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.deepBlack,
              fontWeight: FontWeight.w500,
            ),
            children: isRequired
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isFocused ? AppColors.richGold : const Color(0xFFD9D9D9),
              width: 2,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.richGold.withOpacity(0.1),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: AppTextStyles.bodyMedium,
            readOnly: true,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              border: InputBorder.none,
            ),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                controller.text =
                    '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
              }
            },
          ),
        ),
      ],
    );
  }
}

// TextArea Field Widget
class _TextAreaField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final String placeholder;
  final bool isRequired;

  const _TextAreaField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.placeholder,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.deepBlack,
              fontWeight: FontWeight.w500,
            ),
            children: isRequired
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ]
                : [
                    TextSpan(
                      text: ' (Optional)',
                      style: TextStyle(
                        color: const Color(0xFF8A8A8A),
                      ),
                    ),
                  ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isFocused ? AppColors.richGold : const Color(0xFFD9D9D9),
              width: 2,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.richGold.withOpacity(0.1),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: AppTextStyles.bodyMedium,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

// Product Row Widget
class _ProductRow extends StatefulWidget {
  final SupplierDeliveryItem item;
  final List<Product> products;
  final double maxWidth;
  final Function(int) onProductChanged;
  final Function(int) onQuantityChanged;
  final bool showRemoveButton;
  final VoidCallback onRemove;

  const _ProductRow({
    required this.item,
    required this.products,
    required this.maxWidth,
    required this.onProductChanged,
    required this.onQuantityChanged,
    required this.showRemoveButton,
    required this.onRemove,
  });

  @override
  State<_ProductRow> createState() => _ProductRowState();
}

class _ProductRowState extends State<_ProductRow> {
  final FocusNode _quantityFocusNode = FocusNode();
  final TextEditingController _quantityController = TextEditingController();

  bool _quantityFocused = false;
  bool _pickerHovered = false;

  Product? get _selectedProduct {
    if (widget.item.productId == 0) return null;
    for (final p in widget.products) {
      if (p.id == widget.item.productId) return p;
    }
    return null;
  }

  Future<void> _openProductPicker() async {
    final picked = await showReceiveDeliveryProductPicker(
      context,
      products: widget.products,
      selectedProductId:
          widget.item.productId == 0 ? null : widget.item.productId,
    );
    if (picked != null && mounted) {
      widget.onProductChanged(picked.id);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.item.quantity > 0) {
      _quantityController.text = widget.item.quantity.toString();
    }

    _quantityFocusNode.addListener(() {
      setState(() {
        _quantityFocused = _quantityFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _quantityFocusNode.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Widget _productPickerField() {
    final selected = _selectedProduct;
    final label = selected == null
        ? 'Select product'
        : '${selected.name} (${selected.itemCode})';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _pickerHovered = true),
      onExit: (_) => setState(() => _pickerHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openProductPicker,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _pickerHovered ? AppColors.richGold : const Color(0xFFD9D9D9),
                width: _pickerHovered ? 2 : 2,
              ),
              boxShadow: _pickerHovered
                  ? [
                      BoxShadow(
                        color: AppColors.richGold.withValues(alpha: 0.1),
                        blurRadius: 0,
                        spreadRadius: 3,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: selected == null
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.manage_search_outlined,
                  size: 22,
                  color: _pickerHovered
                      ? AppColors.richGold
                      : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _decoratedQuantityField({bool compactNumericColumn = true}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _quantityFocused
              ? AppColors.richGold
              : const Color(0xFFD9D9D9),
          width: 2,
        ),
        boxShadow: _quantityFocused
            ? [
                BoxShadow(
                  color: AppColors.richGold.withValues(alpha: 0.1),
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Align(
          alignment: Alignment.center,
          child: TextField(
            controller: _quantityController,
            focusNode: _quantityFocusNode,
            keyboardType: TextInputType.number,
            style: AppTextStyles.bodyMedium,
            textAlign:
                compactNumericColumn ? TextAlign.center : TextAlign.start,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: 'Quantity',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 12,
              ),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              final quantity = int.tryParse(value) ?? 0;
              widget.onQuantityChanged(quantity);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final narrow = widget.maxWidth < 480;
    final quantityWidth =
        (widget.maxWidth * 0.22).clamp(96.0, 140.0);

    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _productPickerField(),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _decoratedQuantityField(
                    compactNumericColumn: false,
                  ),
                ),
                if (widget.showRemoveButton) ...[
                  const SizedBox(width: 12),
                  Align(
                    alignment: Alignment.center,
                    child: _RemoveProductButton(onPressed: widget.onRemove),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: _productPickerField(),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: quantityWidth,
            child: _decoratedQuantityField(compactNumericColumn: true),
          ),
          if (widget.showRemoveButton) ...[
            const SizedBox(width: 12),
            Align(
              alignment: Alignment.center,
              child: _RemoveProductButton(onPressed: widget.onRemove),
            ),
          ],
        ],
      ),
    );
  }
}

// Close Button Widget
class _CloseButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _CloseButton({required this.onPressed});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: _isHovered ? AppColors.error.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.close,
              size: 24,
              color: _isHovered ? AppColors.error : const Color(0xFF8A8A8A),
            ),
          ),
        ),
      ),
    );
  }
}

// Remove Product Button
class _RemoveProductButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _RemoveProductButton({required this.onPressed});

  @override
  State<_RemoveProductButton> createState() => _RemoveProductButtonState();
}

class _RemoveProductButtonState extends State<_RemoveProductButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: _isHovered ? AppColors.error.withOpacity(0.1) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: _isHovered ? AppColors.error : const Color(0xFFD9D9D9),
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              Icons.close,
              size: 18,
              color: _isHovered ? AppColors.error : const Color(0xFF8A8A8A),
            ),
          ),
        ),
      ),
    );
  }
}

// Add Product Button
class _AddProductButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AddProductButton({required this.onPressed});

  @override
  State<_AddProductButton> createState() => _AddProductButtonState();
}

class _AddProductButtonState extends State<_AddProductButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: _isHovered ? AppColors.richGold.withOpacity(0.1) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(
            color: AppColors.richGold,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add,
                  size: 16,
                  color: AppColors.richGold,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add Another Product',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.richGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Cancel Button
class _CancelButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _CancelButton({required this.onPressed});

  @override
  State<_CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends State<_CancelButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: _isHovered ? Colors.black.withOpacity(0.05) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(
            color: Color(0xFFD9D9D9),
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                'Cancel',
                style: AppTextStyles.button.copyWith(
                  color: const Color(0xFF2B2B2B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Confirm Button
class _ConfirmButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _ConfirmButton({required this.onPressed});

  @override
  State<_ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<_ConfirmButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: _isHovered ? const Color(0xFF8C6B3F) : AppColors.richGold,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                'Confirm Delivery',
                style: AppTextStyles.button.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
