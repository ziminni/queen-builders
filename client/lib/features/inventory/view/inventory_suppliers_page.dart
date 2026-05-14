import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/supplier.dart';
import '../../../routes/routes.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../models/inventory_categories.dart';
import '../widgets/inventory_page_layout.dart';
import '../viewmodels/inventory_viewmodel.dart';

class InventorySuppliersPage extends StatefulWidget {
  const InventorySuppliersPage({super.key});

  @override
  State<InventorySuppliersPage> createState() => _InventorySuppliersPageState();
}

class _InventorySuppliersPageState extends State<InventorySuppliersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final vm = context.read<InventoryViewModel>();
      await vm.loadProductsFromApi();
      await vm.loadSuppliersFromApi();
      if (!mounted) return;
      vm.setActiveNav('suppliers');
    });
  }

  Future<void> _logout() async {
    await context.read<AuthViewModel>().logout();
    if (mounted) context.go(AppRoutes.login);
  }

  Future<void> _showAddSupplierDialog() async {
    final supplier = await showDialog<Supplier>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const _AddSupplierDialog(),
    );
    if (supplier == null) return;

    try {
      await context.read<InventoryViewModel>().createSupplier(supplier);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${supplier.code} added to suppliers.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not save supplier. Check the server and try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InventoryPageLayout(
      headerTitle: 'Suppliers',
      onLogout: () => _logout(),
      body: Consumer<InventoryViewModel>(
        builder: (context, vm, _) {
          final skuBySupplierCode = <String, int>{};
          for (final p in vm.products) {
            final key = p.supplierCode ?? '';
            if (key.isEmpty) continue;
            skuBySupplierCode[key] = (skuBySupplierCode[key] ?? 0) + 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
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
                            'Supplier directory',
                            style: AppTextStyles.h1.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Preferred vendors, terms, and how many active SKUs reference each.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _showAddSupplierDialog,
                      icon: const Icon(Icons.add_business_outlined, size: 18),
                      label: const Text('Add supplier'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.richGold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: AppTextStyles.button,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...vm.suppliers.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SupplierTile(
                      supplier: s,
                      linkedSkus: skuBySupplierCode[s.code] ?? 0,
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

class _SupplierTile extends StatelessWidget {
  final Supplier supplier;
  final int linkedSkus;

  const _SupplierTile({required this.supplier, required this.linkedSkus});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.storefront_outlined,
                color: AppColors.richGold,
                size: 26,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      style: AppTextStyles.h4.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      supplier.code,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.richGold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.richGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$linkedSkus SKUs in stock file',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _meta(Icons.phone_in_talk_outlined, supplier.contact),
              if (supplier.email != null)
                _meta(Icons.email_outlined, supplier.email!),
              if (supplier.address != null)
                _meta(Icons.location_on_outlined, supplier.address!),
              _meta(Icons.schedule, '${supplier.leadTimeDays} day lead time'),
              _meta(Icons.payments_outlined, supplier.paymentTerms),
            ],
          ),
          if (supplier.categories.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Categories: ${supplier.categories.join(', ')}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(text, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _AddSupplierDialog extends StatefulWidget {
  const _AddSupplierDialog();

  @override
  State<_AddSupplierDialog> createState() => _AddSupplierDialogState();
}

class _AddSupplierDialogState extends State<_AddSupplierDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _paymentTermsController = TextEditingController(text: 'Net 30');
  final _leadTimeController = TextEditingController(text: '3');
  final Set<String> _selectedCategories = {};

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _paymentTermsController.dispose();
    _leadTimeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose at least one category.')),
      );
      return;
    }

    Navigator.of(context).pop(
      Supplier(
        code: _codeController.text.trim().toUpperCase(),
        name: _nameController.text.trim(),
        contact: _contactController.text.trim(),
        email: _optionalText(_emailController),
        address: _optionalText(_addressController),
        paymentTerms: _paymentTermsController.text.trim(),
        leadTimeDays: int.parse(_leadTimeController.text.trim()),
        categories: _selectedCategories.toList()..sort(),
      ),
    );
  }

  String? _optionalText(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  String? _requiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;
    final safeWidth = media.size.width - media.padding.horizontal - 32;
    final safeHeight =
        media.size.height - media.padding.vertical - keyboard - 40;
    final maxWidth = safeWidth.clamp(300.0, 720.0).toDouble();
    final maxHeight = safeHeight
        .clamp(360.0, (media.size.height - keyboard) * 0.92)
        .toDouble();
    final compact = maxWidth < 560;
    final padding = compact ? 20.0 : 28.0;
    final gap = compact ? 12.0 : 16.0;
    final stackFooter = maxWidth < 430;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.richGold, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(padding, padding, padding, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.richGold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.richGold.withValues(alpha: 0.28),
                          ),
                        ),
                        child: Icon(
                          Icons.add_business_outlined,
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
                              'Add Supplier',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.deepBlack,
                                fontSize: compact ? 20 : 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create a vendor profile for inventory deliveries and SKU sourcing.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _ModalCloseButton(
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(padding, 0, padding, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SupplierSectionHeader(title: 'SUPPLIER PROFILE'),
                        SizedBox(height: gap),
                        _ResponsiveFieldGrid(
                          compact: compact,
                          gap: gap,
                          children: [
                            _SupplierTextField(
                              controller: _codeController,
                              label: 'Supplier code',
                              hint: 'SUP-O',
                              isRequired: true,
                              textCapitalization: TextCapitalization.characters,
                              prefixIcon: Icons.badge_outlined,
                              validator: (value) {
                                final requiredError = _requiredText(
                                  value,
                                  'Supplier code',
                                );
                                if (requiredError != null) return requiredError;
                                final exists = context
                                    .read<InventoryViewModel>()
                                    .suppliers
                                    .any(
                                      (supplier) =>
                                          supplier.code.toLowerCase() ==
                                          value!.trim().toLowerCase(),
                                    );
                                if (exists) {
                                  return 'Supplier code already exists';
                                }
                                return null;
                              },
                            ),
                            _SupplierTextField(
                              controller: _nameController,
                              label: 'Supplier name',
                              hint: 'Supplier O - Company Name',
                              isRequired: true,
                              prefixIcon: Icons.storefront_outlined,
                              validator: (value) =>
                                  _requiredText(value, 'Supplier name'),
                            ),
                            _SupplierTextField(
                              controller: _contactController,
                              label: 'Contact',
                              hint: '(02) 8888-0000',
                              isRequired: true,
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone_in_talk_outlined,
                              validator: (value) =>
                                  _requiredText(value, 'Contact'),
                            ),
                            _SupplierTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'orders@supplier.ph',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_outlined,
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty) return null;
                                if (!text.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: gap),
                        _SupplierTextField(
                          controller: _addressController,
                          label: 'Address',
                          hint: 'Warehouse or office address',
                          maxLines: 2,
                          prefixIcon: Icons.location_on_outlined,
                        ),
                        SizedBox(height: compact ? 18 : 24),
                        const _SupplierSectionHeader(title: 'TERMS & COVERAGE'),
                        SizedBox(height: gap),
                        _ResponsiveFieldGrid(
                          compact: compact,
                          gap: gap,
                          children: [
                            _SupplierTextField(
                              controller: _paymentTermsController,
                              label: 'Payment terms',
                              hint: 'Net 30',
                              isRequired: true,
                              prefixIcon: Icons.payments_outlined,
                              validator: (value) =>
                                  _requiredText(value, 'Payment terms'),
                            ),
                            _SupplierTextField(
                              controller: _leadTimeController,
                              label: 'Lead time days',
                              hint: '3',
                              isRequired: true,
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.schedule,
                              validator: (value) {
                                final requiredError = _requiredText(
                                  value,
                                  'Lead time',
                                );
                                if (requiredError != null) return requiredError;
                                final parsed = int.tryParse(value!.trim());
                                if (parsed == null || parsed < 0) {
                                  return 'Enter 0 or more days';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: gap),
                        Text(
                          'Categories',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.deepBlack,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFD9D9D9)),
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final category
                                  in kInventoryProductCategories)
                                _SupplierCategoryChip(
                                  label: category,
                                  selected: _selectedCategories.contains(
                                    category,
                                  ),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedCategories.add(category);
                                      } else {
                                        _selectedCategories.remove(category);
                                      }
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(padding, 16, padding, 16),
                    child: stackFooter
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _ModalActionButton(
                                label: 'Cancel',
                                icon: Icons.close,
                                onPressed: () => Navigator.of(context).pop(),
                                kind: _ModalActionKind.secondary,
                              ),
                              const SizedBox(height: 12),
                              _ModalActionButton(
                                label: 'Save supplier',
                                icon: Icons.check,
                                onPressed: _submit,
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: _ModalActionButton(
                                  label: 'Cancel',
                                  icon: Icons.close,
                                  onPressed: () => Navigator.of(context).pop(),
                                  kind: _ModalActionKind.secondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ModalActionButton(
                                  label: 'Save supplier',
                                  icon: Icons.check,
                                  onPressed: _submit,
                                ),
                              ),
                            ],
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
}

class _SupplierSectionHeader extends StatelessWidget {
  final String title;

  const _SupplierSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.labelMedium.copyWith(
        color: AppColors.richGold,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }
}

class _ResponsiveFieldGrid extends StatelessWidget {
  final bool compact;
  final double gap;
  final List<Widget> children;

  const _ResponsiveFieldGrid({
    required this.compact,
    required this.gap,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) SizedBox(height: gap),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class _SupplierTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final bool isRequired;
  final IconData? prefixIcon;

  const _SupplierTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.isRequired = false,
    this.prefixIcon,
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
              fontWeight: FontWeight.w600,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          maxLines: maxLines,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.deepBlack),
          cursorColor: AppColors.richGold,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: 18, color: AppColors.textSecondary),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 36,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            errorStyle: AppTextStyles.labelSmall.copyWith(
              color: AppColors.error,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD9D9D9), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD9D9D9), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.richGold, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }
}

class _SupplierCategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _SupplierCategoryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: true,
      checkmarkColor: Colors.white,
      backgroundColor: Colors.white,
      selectedColor: AppColors.richGold,
      side: BorderSide(
        color: selected ? AppColors.richGold : const Color(0xFFD9D9D9),
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: selected ? Colors.white : AppColors.deepBlack,
        fontWeight: FontWeight.w600,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ModalCloseButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _ModalCloseButton({required this.onPressed});

  @override
  State<_ModalCloseButton> createState() => _ModalCloseButtonState();
}

class _ModalCloseButtonState extends State<_ModalCloseButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: _hovered
            ? AppColors.error.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.close,
              size: 22,
              color: _hovered ? AppColors.error : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

enum _ModalActionKind { primary, secondary }

class _ModalActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final _ModalActionKind kind;

  const _ModalActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.kind = _ModalActionKind.primary,
  });

  @override
  State<_ModalActionButton> createState() => _ModalActionButtonState();
}

class _ModalActionButtonState extends State<_ModalActionButton> {
  bool _hovered = false;

  bool get _primary => widget.kind == _ModalActionKind.primary;

  @override
  Widget build(BuildContext context) {
    final bg = _primary
        ? (_hovered ? const Color(0xFF8C6B3F) : AppColors.richGold)
        : (_hovered
              ? Colors.black.withValues(alpha: 0.05)
              : Colors.transparent);
    final fg = _primary ? Colors.white : const Color(0xFF2B2B2B);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: _primary ? AppColors.richGold : const Color(0xFFD9D9D9),
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            transform: Matrix4.translationValues(
              0,
              _hovered && _primary ? -1 : 0,
              0,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 18, color: fg),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.button.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
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
}
