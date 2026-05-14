import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/inventory_viewmodel.dart';
import 'inventory_header.dart';
import 'inventory_sidebar.dart';
import '../utils/inventory_navigation.dart';

class InventoryPageLayout extends StatelessWidget {
  final String headerTitle;
  final Widget body;
  final VoidCallback onLogout;

  const InventoryPageLayout({
    super.key,
    required this.headerTitle,
    required this.body,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          body: Row(
            children: [
              InventorySidebar(
                activeNav: viewModel.activeNav,
                isOpen: viewModel.sidebarOpen,
                onNavChange: (nav) =>
                    navigateInventorySection(context, viewModel, nav),
                onLogout: onLogout,
              ),
              Expanded(
                child: Column(
                  children: [
                    InventoryHeader(
                      title: headerTitle,
                      searchQuery: viewModel.searchQuery,
                      onSearchChanged: viewModel.setSearchQuery,
                      onMenuToggle: viewModel.toggleSidebar,
                      onNotificationTap: () {},
                      onProfileTap: () {},
                    ),
                    Expanded(child: body),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
