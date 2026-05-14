import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/scroll/desktop_smooth_scroll.dart';
import '../../../data/models/product.dart';
import '../models/inventory_categories.dart';

/// Full-screen style modal to pick a catalog line for receive delivery.
Future<Product?> showReceiveDeliveryProductPicker(
  BuildContext context, {
  required List<Product> products,
  int? selectedProductId,
}) {
  return showDialog<Product>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (ctx) => ReceiveDeliveryProductPickerDialog(
      products: products,
      selectedProductId: selectedProductId,
    ),
  );
}

class ReceiveDeliveryProductPickerDialog extends StatefulWidget {
  final List<Product> products;
  final int? selectedProductId;

  const ReceiveDeliveryProductPickerDialog({
    super.key,
    required this.products,
    this.selectedProductId,
  });

  @override
  State<ReceiveDeliveryProductPickerDialog> createState() =>
      _ReceiveDeliveryProductPickerDialogState();
}

class _ReceiveDeliveryProductPickerDialogState
    extends State<ReceiveDeliveryProductPickerDialog> {
  late final TextEditingController _search;
  final ScrollController _scrollController = ScrollController();
  String _categoryFilter = '';

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Product> get _filtered {
    final q = _search.text.trim().toLowerCase();
    return widget.products.where((p) {
      if (_categoryFilter.isNotEmpty && p.category != _categoryFilter) {
        return false;
      }
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.itemCode.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
    }).toList();
  }

  List<String> get _categoryChoices =>
      ['', ...kInventoryProductCategories];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxW = media.size.width.clamp(0.0, 620.0);
    final maxH = (media.size.height * 0.85).clamp(360.0, 620.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: maxW,
        constraints: BoxConstraints(maxHeight: maxH),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.richGold, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Select product',
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                controller: _search,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search by name, SKU, brand, category…',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  prefixIcon: const Icon(Icons.search, size: 22),
                  filled: true,
                  fillColor: const Color(0xFFFAFAFA),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD9D9D9), width: 2),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _categoryFilter,
                        isExpanded: true,
                        hint: Text(
                          'All categories',
                          style: AppTextStyles.bodySmall,
                        ),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down, size: 22),
                        items: _categoryChoices.map((c) {
                          return DropdownMenuItem<String>(
                            value: c,
                            child: Text(
                              c.isEmpty ? 'All categories' : c,
                              style: AppTextStyles.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() {
                          _categoryFilter = v ?? '';
                        }),
                      ),
                    ),
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
                  child: _filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'No products match your search or filter.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                          itemCount: _filtered.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final p = _filtered[index];
                            final isCurrent =
                                widget.selectedProductId != null &&
                                    widget.selectedProductId == p.id;
                            return Material(
                              color: isCurrent
                                  ? AppColors.richGold.withValues(alpha: 0.08)
                                  : Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    Navigator.of(context).pop<Product>(p),
                                hoverColor:
                                    AppColors.richGold.withValues(alpha: 0.06),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              p.name,
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${p.itemCode} · ${p.category}',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                color: AppColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Stock: ${p.stock}',
                                            style: AppTextStyles.labelSmall
                                                .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            p.unit,
                                            style: AppTextStyles.labelSmall
                                                .copyWith(
                                              color: AppColors.textSecondary,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
