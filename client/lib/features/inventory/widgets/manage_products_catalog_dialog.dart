import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/scroll/desktop_smooth_scroll.dart';
import '../../../data/models/product.dart';
import '../models/inventory_categories.dart';
import '../viewmodels/inventory_viewmodel.dart';
import 'add_product_dialog.dart';

Future<void> showManageProductsCatalogDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (ctx) => const ManageProductsCatalogDialog(),
  );
}

class ManageProductsCatalogDialog extends StatefulWidget {
  const ManageProductsCatalogDialog({super.key});

  @override
  State<ManageProductsCatalogDialog> createState() =>
      _ManageProductsCatalogDialogState();
}

class _ManageProductsCatalogDialogState
    extends State<ManageProductsCatalogDialog> {
  late final TextEditingController _search;
  final ScrollController _scrollController = ScrollController();
  String _categoryFilter = '';

  List<String> get _categoryChoices =>
      ['', ...kInventoryProductCategories];

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

  List<Product> _filtered(List<Product> all) {
    final q = _search.text.trim().toLowerCase();
    return all.where((p) {
      if (_categoryFilter.isNotEmpty && p.category != _categoryFilter) {
        return false;
      }
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.itemCode.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<void> _confirmDelete(
      BuildContext context, InventoryViewModel vm, Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove product?', style: AppTextStyles.h3),
        content: Text(
          'Delete "${p.name}" (${p.itemCode}) from the catalog? Stock and '
          'history in this session will no longer reference this line.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppTextStyles.button.copyWith(
                    color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: AppTextStyles.button.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      try {
        await vm.deleteProduct(p.id);
        if (mounted) setState(() {});
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Could not delete the product. Try again.')),
          );
        }
      }
    }
  }

  void _openEdit(BuildContext context, InventoryViewModel vm, Product p) {
    showDialog<void>(
      context: context,
      builder: (dc) => AddProductDialog(
        categories: kInventoryProductCategories,
        productToEdit: p,
        onCommit: vm.commitProductForm,
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxW = media.size.width.clamp(320.0, 720.0);
    final maxH = (media.size.height * 0.88).clamp(400.0, 720.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Consumer<InventoryViewModel>(
        builder: (context, vm, _) {
          final items = _filtered(vm.products);

          return Container(
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'All products',
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: TextField(
                    controller: _search,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText:
                          'Search by name, SKU, brand, category, description…',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon:
                          const Icon(Icons.search, size: 22),
                      filled: true,
                      fillColor: const Color(0xFFFAFAFA),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFFD9D9D9)),
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
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFFD9D9D9), width: 2),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _categoryFilter,
                            isExpanded: true,
                            style: AppTextStyles.bodySmall,
                            icon: const Icon(Icons.keyboard_arrow_down,
                                size: 22),
                            items: _categoryChoices.map((c) {
                              return DropdownMenuItem<String>(
                                value: c,
                                child: Text(
                                  c.isEmpty ? 'All categories' : c,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (v) {
                              setState(() {
                                _categoryFilter = v ?? '';
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Text(
                            vm.products.isEmpty
                                ? 'No products in catalog yet.'
                                : 'No products match your search or filter.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ScrollConfiguration(
                          behavior: const DesktopSmoothScrollBehavior(),
                          child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            child: ListView.separated(
                              controller: _scrollController,
                              padding:
                                  const EdgeInsets.fromLTRB(12, 0, 12, 16),
                              itemCount: items.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final p = items[index];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  title: Text(
                                    p.name,
                                    style: AppTextStyles.bodyMedium
                                        .copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    '${p.itemCode} · ${p.category} · Stock: ${p.stock} ${p.unit}',
                                    style: AppTextStyles.bodySmall
                                        .copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Edit',
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          color: AppColors.richGold,
                                          size: 22,
                                        ),
                                        onPressed: () =>
                                            _openEdit(context, vm, p),
                                      ),
                                      IconButton(
                                        tooltip: 'Delete',
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: AppColors.error,
                                          size: 22,
                                        ),
                                        onPressed: () =>
                                            _confirmDelete(context, vm, p),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
