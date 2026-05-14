import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../routes/routes.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../widgets/inventory_page_layout.dart';
import '../viewmodels/inventory_viewmodel.dart';

class InventorySettingsPage extends StatefulWidget {
  const InventorySettingsPage({super.key});

  @override
  State<InventorySettingsPage> createState() => _InventorySettingsPageState();
}

class _InventorySettingsPageState extends State<InventorySettingsPage> {
  bool _emailAlerts = true;
  bool _digestWeekly = false;
  final _defaultLocation = TextEditingController(text: 'Main warehouse — Zone A');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<InventoryViewModel>().setActiveNav('settings');
    });
  }

  @override
  void dispose() {
    _defaultLocation.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await context.read<AuthViewModel>().logout();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return InventoryPageLayout(
      headerTitle: 'Settings',
      onLogout: () => _logout(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock manager preferences',
              style: AppTextStyles.h1.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Local-only options for this build. Connect to your account API when available.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: 480,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: AppTextStyles.h4.copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Email when SKU hits critical'),
                    subtitle: Text(
                      'Uses the address on your profile once email is connected.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    value: _emailAlerts,
                    activeThumbColor: AppColors.deepBlack,
                    activeTrackColor: AppColors.richGold.withOpacity(0.5),
                    onChanged: (v) => setState(() => _emailAlerts = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Weekly inventory digest'),
                    subtitle: Text(
                      'Summary of movement and low-stock SKUs.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    value: _digestWeekly,
                    activeThumbColor: AppColors.deepBlack,
                    activeTrackColor: AppColors.richGold.withOpacity(0.5),
                    onChanged: (v) => setState(() => _digestWeekly = v),
                  ),
                  const Divider(height: 32),
                  Text(
                    'Receiving defaults',
                    style: AppTextStyles.h4.copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Default putaway location',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _defaultLocation,
                    decoration: InputDecoration(
                      hintText: 'e.g. Bay 3 — Racking B',
                      border: OutlineInputBorder(
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Preferences saved locally for this session.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.richGold,
                      side: const BorderSide(color: AppColors.richGold, width: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Save preferences'),
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
