import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/scroll/desktop_smooth_scroll.dart';
import '../../../data/models/product.dart';
import '../models/new_product.dart';

class AddProductDialog extends StatefulWidget {
  final List<String> categories;
  final Future<void> Function(NewProduct data, int? existingProductId) onCommit;
  final Product? productToEdit;

  const AddProductDialog({
    super.key,
    required this.categories,
    required this.onCommit,
    this.productToEdit,
  });

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final NewProduct _product = NewProduct();
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, bool> _isFocused = {};
  final ScrollController _scrollController = ScrollController();

  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      'itemCode': TextEditingController(),
      'brand': TextEditingController(),
      'subcategory': TextEditingController(),
      'name': TextEditingController(),
      'description': TextEditingController(),
      'specifications': TextEditingController(),
      'costPrice': TextEditingController(),
      'markupPercent': TextEditingController(),
      'sellingPrice': TextEditingController(),
      'unit': TextEditingController(),
    };

    final fields = [
      'itemCode',
      'brand',
      'category',
      'subcategory',
      'name',
      'description',
      'specifications',
      'unit',
      'costPrice',
      'markupPercent',
      'sellingPrice',
    ];

    for (final field in fields) {
      _focusNodes[field] = FocusNode();
      _focusNodes[field]!.addListener(() {
        setState(() {
          _isFocused[field] = _focusNodes[field]!.hasFocus;
        });
      });
    }

    final e = widget.productToEdit;
    if (e != null) {
      _controllers['itemCode']!.text = e.itemCode;
      _controllers['brand']!.text = e.brand;
      _controllers['subcategory']!.text = e.subcategory;
      _controllers['name']!.text = e.name;
      _controllers['description']!.text = e.description;
      _controllers['specifications']!.text = e.specifications;
      _controllers['costPrice']!.text = e.costPrice.toString();
      _controllers['markupPercent']!.text = e.markupPercent.toString();
      _controllers['sellingPrice']!.text = e.sellingPrice.toString();
      _controllers['unit']!.text = e.unit;
      _product.category = e.category;
      _product.sellingPrice = _controllers['sellingPrice']!.text;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    _focusNodes.forEach((_, node) => node.dispose());
    super.dispose();
  }

  void _calculateSellingPrice() {
    final cost = double.tryParse(_controllers['costPrice']!.text) ?? 0;
    final markup = double.tryParse(_controllers['markupPercent']!.text) ?? 0;
    final selling = cost + (cost * markup / 100);
    _controllers['sellingPrice']!.text = selling.toStringAsFixed(2);
    setState(() {
      _product.sellingPrice = _controllers['sellingPrice']!.text;
    });
  }

  NewProduct _collectProduct() {
    return NewProduct(
      itemCode: _controllers['itemCode']!.text.trim(),
      name: _controllers['name']!.text.trim(),
      description: _controllers['description']!.text.trim(),
      brand: _controllers['brand']!.text.trim(),
      category: _product.category.trim(),
      subcategory: _controllers['subcategory']!.text.trim(),
      specifications: _controllers['specifications']!.text.trim(),
      unit: _controllers['unit']!.text.trim(),
      costPrice: _controllers['costPrice']!.text.trim(),
      markupPercent: _controllers['markupPercent']!.text.trim(),
      sellingPrice: _controllers['sellingPrice']!.text.trim(),
    );
  }

  Future<void> _handleSubmit() async {
    final name = _controllers['name']!.text.trim();
    final brand = _controllers['brand']!.text.trim();
    if (name.isEmpty ||
        _product.category.trim().isEmpty ||
        brand.isEmpty) {
      _showAlert(
          'Please fill in all required fields (Name, Category, Brand)');
      return;
    }

    try {
      await widget.onCommit(_collectProduct(), widget.productToEdit?.id);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        _showAlert(
            'Could not save the product. Check that the server is running and try again.');
      }
    }
  }

  void _showAlert(String message) {
    showDialog<void>(
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

    final narrow = maxW < 520;
    final pad = narrow ? 20.0 : 32.0;
    final gap = narrow ? 12.0 : 16.0;
    final stackFooter = maxW < 380;

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
              Padding(
                padding: EdgeInsets.fromLTRB(pad, pad, pad, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.productToEdit == null
                            ? 'Add New Product'
                            : 'Edit Product',
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
              ),
              Expanded(
                child: ScrollConfiguration(
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
                      padding: EdgeInsets.fromLTRB(pad, 0, pad, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionHeader(title: 'BASIC INFORMATION'),
                          SizedBox(height: gap),
                          if (narrow) ...[
                            _SmallInputField(
                              label: 'SKU / Item Code',
                              controller: _controllers['itemCode']!,
                              focusNode: _focusNodes['itemCode']!,
                              isFocused: _isFocused['itemCode'] ?? false,
                              placeholder: 'e.g., PNT001-BOY-WHT-1L',
                              onChanged: (value) =>
                                  setState(() => _product.itemCode = value),
                            ),
                            SizedBox(height: gap),
                            _SmallInputField(
                              label: 'Brand',
                              controller: _controllers['brand']!,
                              focusNode: _focusNodes['brand']!,
                              isFocused: _isFocused['brand'] ?? false,
                              placeholder: 'e.g., Boysen, Holcim',
                              isRequired: true,
                              onChanged: (value) =>
                                  setState(() => _product.brand = value),
                            ),
                          ] else
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _SmallInputField(
                                    label: 'SKU / Item Code',
                                    controller: _controllers['itemCode']!,
                                    focusNode: _focusNodes['itemCode']!,
                                    isFocused:
                                        _isFocused['itemCode'] ?? false,
                                    placeholder: 'e.g., PNT001-BOY-WHT-1L',
                                    onChanged: (value) => setState(
                                        () => _product.itemCode = value),
                                  ),
                                ),
                                SizedBox(width: gap),
                                Expanded(
                                  child: _SmallInputField(
                                    label: 'Brand',
                                    controller: _controllers['brand']!,
                                    focusNode: _focusNodes['brand']!,
                                    isFocused: _isFocused['brand'] ?? false,
                                    placeholder: 'e.g., Boysen, Holcim',
                                    isRequired: true,
                                    onChanged: (value) => setState(
                                        () => _product.brand = value),
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: gap),
                          if (narrow) ...[
                            _SmallDropdownField(
                              label: 'Category',
                              value: _product.category.isEmpty
                                  ? null
                                  : _product.category,
                              focusNode: _focusNodes['category']!,
                              isFocused: _isFocused['category'] ?? false,
                              items: widget.categories,
                              isRequired: true,
                              onChanged: (value) => setState(
                                  () => _product.category = value ?? ''),
                            ),
                            SizedBox(height: gap),
                            _SmallInputField(
                              label: 'Subcategory',
                              controller: _controllers['subcategory']!,
                              focusNode: _focusNodes['subcategory']!,
                              isFocused:
                                  _isFocused['subcategory'] ?? false,
                              placeholder: 'e.g., Interior Paint',
                              onChanged: (value) => setState(
                                  () => _product.subcategory = value),
                            ),
                          ] else
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _SmallDropdownField(
                                    label: 'Category',
                                    value: _product.category.isEmpty
                                        ? null
                                        : _product.category,
                                    focusNode: _focusNodes['category']!,
                                    isFocused:
                                        _isFocused['category'] ?? false,
                                    items: widget.categories,
                                    isRequired: true,
                                    onChanged: (value) => setState(() =>
                                        _product.category = value ?? ''),
                                  ),
                                ),
                                SizedBox(width: gap),
                                Expanded(
                                  child: _SmallInputField(
                                    label: 'Subcategory',
                                    controller: _controllers['subcategory']!,
                                    focusNode: _focusNodes['subcategory']!,
                                    isFocused:
                                        _isFocused['subcategory'] ?? false,
                                    placeholder: 'e.g., Interior Paint',
                                    onChanged: (value) => setState(() =>
                                        _product.subcategory = value),
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: gap),
                          _SmallInputField(
                            label: 'Product Name',
                            controller: _controllers['name']!,
                            focusNode: _focusNodes['name']!,
                            isFocused: _isFocused['name'] ?? false,
                            placeholder: 'e.g., Boysen Premium White 4L',
                            isRequired: true,
                            onChanged: (value) =>
                                setState(() => _product.name = value),
                          ),
                          SizedBox(height: gap),
                          _SmallTextAreaField(
                            label: 'Description',
                            controller: _controllers['description']!,
                            focusNode: _focusNodes['description']!,
                            isFocused: _isFocused['description'] ?? false,
                            placeholder: 'Brief product description',
                            onChanged: (value) => setState(
                                () => _product.description = value),
                          ),
                          SizedBox(height: gap),
                          _SmallInputField(
                            label: 'Specifications',
                            controller: _controllers['specifications']!,
                            focusNode: _focusNodes['specifications']!,
                            isFocused:
                                _isFocused['specifications'] ?? false,
                            placeholder: 'e.g., 4L, White, Latex',
                            onChanged: (value) => setState(
                                () => _product.specifications = value),
                          ),
                          SizedBox(height: gap),
                          _SmallInputField(
                            label: 'Unit',
                            controller: _controllers['unit']!,
                            focusNode: _focusNodes['unit']!,
                            isFocused: _isFocused['unit'] ?? false,
                            placeholder: 'e.g., pieces, bags, liters',
                            onChanged: (value) =>
                                setState(() => _product.unit = value),
                          ),
                          SizedBox(height: narrow ? 16 : 24),
                          const _SectionHeader(title: 'PRICING'),
                          SizedBox(height: gap),
                          if (narrow) ...[
                            _SmallInputField(
                              label: 'Cost Price (₱)',
                              controller: _controllers['costPrice']!,
                              focusNode: _focusNodes['costPrice']!,
                              isFocused: _isFocused['costPrice'] ?? false,
                              placeholder: 'Purchase price',
                              inputType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              onChanged: (value) {
                                setState(() {
                                  _product.costPrice = value;
                                  _calculateSellingPrice();
                                });
                              },
                            ),
                            SizedBox(height: gap),
                            _SmallInputField(
                              label: 'Markup %',
                              controller: _controllers['markupPercent']!,
                              focusNode: _focusNodes['markupPercent']!,
                              isFocused:
                                  _isFocused['markupPercent'] ?? false,
                              placeholder: 'Profit margin %',
                              inputType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              onChanged: (value) {
                                setState(() {
                                  _product.markupPercent = value;
                                  _calculateSellingPrice();
                                });
                              },
                            ),
                          ] else
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _SmallInputField(
                                    label: 'Cost Price (₱)',
                                    controller: _controllers['costPrice']!,
                                    focusNode: _focusNodes['costPrice']!,
                                    isFocused:
                                        _isFocused['costPrice'] ?? false,
                                    placeholder: 'Purchase price',
                                    inputType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    onChanged: (value) {
                                      setState(() {
                                        _product.costPrice = value;
                                        _calculateSellingPrice();
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: gap),
                                Expanded(
                                  child: _SmallInputField(
                                    label: 'Markup %',
                                    controller:
                                        _controllers['markupPercent']!,
                                    focusNode:
                                        _focusNodes['markupPercent']!,
                                    isFocused:
                                        _isFocused['markupPercent'] ?? false,
                                    placeholder: 'Profit margin %',
                                    inputType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    onChanged: (value) {
                                      setState(() {
                                        _product.markupPercent = value;
                                        _calculateSellingPrice();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: gap),
                          _SmallInputField(
                            label: 'Selling Price (₱)',
                            controller: _controllers['sellingPrice']!,
                            focusNode: _focusNodes['sellingPrice']!,
                            isFocused:
                                _isFocused['sellingPrice'] ?? false,
                            placeholder: 'Retail price',
                            inputType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            backgroundColor: const Color(0xFFFAFAFA),
                            suffix: '(Auto-calculated)',
                            onChanged: (value) => setState(
                                () => _product.sellingPrice = value),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.white,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(pad, 16, pad, 16),
                    child: stackFooter
                        ? Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              _CancelButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(),
                              ),
                              const SizedBox(height: 12),
                              _SubmitButton(
                                label: widget.productToEdit == null
                                    ? 'Add Product'
                                    : 'Save changes',
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
                                child: _SubmitButton(
                                  label: widget.productToEdit == null
                                      ? 'Add Product'
                                      : 'Save changes',
                                  onPressed: _handleSubmit,
                                ),
                              ),
                            ],
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

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.labelMedium.copyWith(
        color: AppColors.richGold,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _SmallInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final String placeholder;
  final bool isRequired;
  final ValueChanged<String> onChanged;
  final TextInputType? inputType;
  final Color? backgroundColor;
  final String? suffix;

  const _SmallInputField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.placeholder,
    this.isRequired = false,
    required this.onChanged,
    this.inputType,
    this.backgroundColor,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.deepBlack,
              fontWeight: FontWeight.w500,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error),
                ),
              if (suffix != null)
                TextSpan(
                  text: ' $suffix',
                  style: const TextStyle(
                    color: Color(0xFF8A8A8A),
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isFocused ? AppColors.richGold : const Color(0xFFD9D9D9),
              width: 2,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: inputType,
            style: AppTextStyles.bodySmall,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: InputBorder.none,
              isDense: true,
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _SmallTextAreaField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final String placeholder;
  final ValueChanged<String> onChanged;

  const _SmallTextAreaField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.placeholder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.deepBlack,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isFocused ? AppColors.richGold : const Color(0xFFD9D9D9),
              width: 2,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: AppTextStyles.bodySmall,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: InputBorder.none,
              isDense: true,
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _SmallDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final FocusNode focusNode;
  final bool isFocused;
  final List<String> items;
  final bool isRequired;
  final ValueChanged<String?> onChanged;

  const _SmallDropdownField({
    required this.label,
    required this.value,
    required this.focusNode,
    required this.isFocused,
    required this.items,
    this.isRequired = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.bodySmall.copyWith(
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
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isFocused ? AppColors.richGold : const Color(0xFFD9D9D9),
              width: 2,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            focusNode: focusNode,
            isExpanded: true,
            isDense: true,
            menuMaxHeight: 280,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: InputBorder.none,
              isDense: true,
            ),
            hint: Text(
              'Select Category',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: AppTextStyles.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            selectedItemBuilder: (context) {
              return items.map((item) {
                return Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    item,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList();
            },
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

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
        color: _isHovered
            ? AppColors.error.withOpacity(0.1)
            : Colors.transparent,
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
        color:
            _isHovered ? Colors.black.withOpacity(0.05) : Colors.transparent,
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

class _SubmitButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;

  const _SubmitButton({
    required this.onPressed,
    required this.label,
  });

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
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
                widget.label,
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
