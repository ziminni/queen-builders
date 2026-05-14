import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/routes.dart';
import '../viewmodels/inventory_viewmodel.dart';

void navigateInventorySection(
  BuildContext context,
  InventoryViewModel viewModel,
  String navId,
) {
  viewModel.setActiveNav(navId);
  switch (navId) {
    case 'dashboard':
      context.go(AppRoutes.inventoryDashboard);
      break;
    case 'inventory':
      context.go(AppRoutes.inventoryProducts);
      break;
    case 'categories':
      context.go(AppRoutes.inventoryCategories);
      break;
    case 'suppliers':
      context.go(AppRoutes.inventorySuppliers);
      break;
    case 'alerts':
      context.go(AppRoutes.inventoryAlerts);
      break;
    case 'deliveries':
      context.go(AppRoutes.inventoryDeliveries);
      break;
    case 'reports':
      context.go(AppRoutes.inventoryReports);
      break;
    case 'settings':
      context.go(AppRoutes.inventorySettings);
      break;
    default:
      context.go(AppRoutes.inventoryDashboard);
  }
}
