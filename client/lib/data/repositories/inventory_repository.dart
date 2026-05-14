import '../sources/remote/inventory_remote_source.dart';
import '../../features/inventory/models/inventory_delivery_record.dart';
import '../../features/inventory/models/new_product.dart';
import '../../features/inventory/models/supplier_delivery_item.dart';
import '../models/product.dart';
import '../models/supplier.dart';

class InventoryRepository {
  InventoryRepository({InventoryRemoteSource? remote})
    : _remote = remote ?? InventoryRemoteSource();

  final InventoryRemoteSource _remote;

  Future<List<Product>> fetchProducts() => _remote.fetchProducts();

  Future<List<InventoryDeliveryRecord>> fetchDeliveries() =>
      _remote.fetchDeliveries();

  Future<List<Supplier>> fetchSuppliers() => _remote.fetchSuppliers();

  Future<Supplier> createSupplier(Supplier supplier) =>
      _remote.createSupplier(supplier);

  Future<Map<String, dynamic>> checkoutPos({
    required List<Map<String, dynamic>> lines,
    required String paymentMethod,
    required bool isPayLater,
    String customerName = '',
    String customerPhone = '',
    String customerAddress = '',
  }) => _remote.checkoutPos(
    lines: lines,
    paymentMethod: paymentMethod,
    isPayLater: isPayLater,
    customerName: customerName,
    customerPhone: customerPhone,
    customerAddress: customerAddress,
  );

  Future<List<Map<String, dynamic>>> fetchPosSalesRaw() =>
      _remote.fetchPosSalesRaw();

  Future<void> createProduct(NewProduct n) => _remote.createProduct(n);

  Future<void> updateProduct(int id, NewProduct n) =>
      _remote.updateProduct(id, n);

  Future<void> deleteProduct(int id) => _remote.deleteProduct(id);

  Future<void> receiveDelivery({
    required String supplierName,
    String? supplierCode,
    required String warehouseLocation,
    required String invoiceNumber,
    required String receivedBy,
    required String notes,
    required List<SupplierDeliveryItem> items,
  }) => _remote.receiveDelivery(
    supplierName: supplierName,
    supplierCode: supplierCode,
    warehouseLocation: warehouseLocation,
    invoiceNumber: invoiceNumber,
    receivedBy: receivedBy,
    notes: notes,
    items: items,
  );
}
