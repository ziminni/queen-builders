import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../routes/routes.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../models/inventory_categories.dart';
import '../widgets/inventory_page_layout.dart';
import '../viewmodels/inventory_viewmodel.dart';

class InventoryCategoriesPage extends StatefulWidget {
  const InventoryCategoriesPage({super.key});

  @override
  State<InventoryCategoriesPage> createState() => _InventoryCategoriesPageState();
}

class _InventoryCategoriesPageState extends State<InventoryCategoriesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final vm = context.read<InventoryViewModel>();
      await vm.loadProductsFromApi();
      if (!mounted) return;
      vm.setActiveNav('categories');
    });
  }

  Future<void> _logout() async {
    await context.read<AuthViewModel>().logout();
    if (mounted) context.go(AppRoutes.login);
  }

  void _openMaterialsForCategory(BuildContext context, String categoryName) {
    context.read<InventoryViewModel>().setActiveNav('inventory');
    final target = Uri(
      path: AppRoutes.inventoryProducts,
      queryParameters: {'category': categoryName},
    );
    context.go(target.toString());
  }

  @override
  Widget build(BuildContext context) {
    return InventoryPageLayout(
      headerTitle: 'Categories',
      onLogout: () => _logout(),
      body: Consumer<InventoryViewModel>(
        builder: (context, vm, _) {
          final byCat = <String, int>{};
          for (final p in vm.products) {
            byCat[p.category] = (byCat[p.category] ?? 0) + 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product categories',
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Catalog groups and how many SKUs sit in each. Click a category to open all materials in that group — search and filters are on the next screen.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth;
                    const gap = 14.0;
                    final columns = w > 1100
                        ? 3
                        : w > 700
                            ? 2
                            : 1;
                    final cardWidth = columns > 0
                        ? (w - (columns - 1) * gap) / columns
                        : w;

                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (final def in kInventoryCategoryDefinitions)
                          SizedBox(
                            width: cardWidth,
                            child: _CategoryCard(
                              name: def.name,
                              description: def.description,
                              productCount: byCat[def.name] ?? 0,
                              onTap: () => _openMaterialsForCategory(
                                context,
                                def.name,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final String name;
  final String description;
  final int productCount;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.description,
    required this.productCount,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    const titleLinesHeight = 40.0;
    const descriptionLinesHeight = 48.0;

    return Semantics(
      button: true,
      label: 'View materials in ${widget.name}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _hover ? AppColors.richGold : AppColors.border,
                width: _hover ? 2 : 1,
              ),
              boxShadow: _hover
                  ? [
                      BoxShadow(
                        color: AppColors.richGold.withValues(alpha: 0.14),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.category_outlined,
                          color: AppColors.richGold,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: titleLinesHeight,
                          child: Text(
                            widget.name,
                            style: AppTextStyles.h4.copyWith(
                              fontSize: 15,
                              height: 1.25,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: descriptionLinesHeight,
                    child: Text(
                      widget.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.productCount} ${widget.productCount == 1 ? 'product' : 'products'}',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'View materials →',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.richGold,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
