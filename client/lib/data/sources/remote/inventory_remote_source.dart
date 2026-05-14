import '../../../core/network/api_config.dart';
import '../../../core/services/api_service.dart';
import '../../../features/inventory/models/inventory_delivery_record.dart';
import '../../../features/inventory/models/new_product.dart';
import '../../../features/inventory/models/supplier_delivery_item.dart';
import '../../models/product.dart';
import '../../models/supplier.dart';

/// Inventory HTTP API (camelCase JSON matches Django serializers).
class InventoryRemoteSource {
  InventoryRemoteSource({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<List<Product>> fetchProducts() async {
    final r = await _api.dio.get(ApiConfig.inventoryProducts);
    final list = r.data as List<dynamic>;
    return list
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<InventoryDeliveryRecord>> fetchDeliveries() async {
    final r = await _api.dio.get(ApiConfig.inventoryDeliveries);
    final list = r.data as List<dynamic>;
    return list
        .map(
          (e) => InventoryDeliveryRecord.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  Future<List<Supplier>> fetchSuppliers() async {
    final r = await _api.dio.get(ApiConfig.inventorySuppliers);
    final list = r.data as List<dynamic>;
    return list
        .map((e) => Supplier.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Supplier> createSupplier(Supplier supplier) async {
    final r = await _api.dio.post(
      ApiConfig.inventorySuppliers,
      data: supplier.toJson(),
    );
    return Supplier.fromJson(Map<String, dynamic>.from(r.data as Map));
  }

  Future<Map<String, dynamic>> checkoutPos({
    required List<Map<String, dynamic>> lines,
    required String paymentMethod,
    required bool isPayLater,
    String customerName = '',
    String customerPhone = '',
    String customerAddress = '',
  }) async {
    final r = await _api.dio.post(
      ApiConfig.inventoryPosCheckout,
      data: {
        'lines': lines,
        'paymentMethod': paymentMethod,
        'isPayLater': isPayLater,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerAddress': customerAddress,
      },
    );
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<List<Map<String, dynamic>>> fetchPosSalesRaw() async {
    final r = await _api.dio.get(ApiConfig.inventoryPosSales);
    final list = r.data as List<dynamic>;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> createProduct(NewProduct n) async {
    await _api.dio.post(ApiConfig.inventoryProducts, data: _newProductBody(n));
  }

  Future<void> updateProduct(int id, NewProduct n) async {
    await _api.dio.patch(
      ApiConfig.inventoryProductDetail(id),
      data: _patchBody(n),
    );
  }

  Future<void> deleteProduct(int id) async {
    await _api.dio.delete(ApiConfig.inventoryProductDetail(id));
  }

  Future<void> receiveDelivery({
    required String supplierName,
    String? supplierCode,
    required String warehouseLocation,
    required String invoiceNumber,
    required String receivedBy,
    required String notes,
    required List<SupplierDeliveryItem> items,
  }) async {
    await _api.dio.post(
      ApiConfig.inventoryReceive,
      data: {
        'supplierName': supplierName,
        'supplierCode': supplierCode,
        'warehouseLocation': warehouseLocation,
        'invoiceNumber': invoiceNumber,
        'receivedBy': receivedBy,
        'notes': notes,
        'items': [
          for (final i in items)
            {'productId': i.productId, 'quantity': i.quantity},
        ],
      },
    );
  }

  Map<String, dynamic> _newProductBody(NewProduct n) {
    final unit = n.unit.trim().isEmpty ? 'unit' : n.unit.trim();
    return {
      'itemCode': n.itemCode.trim(),
      'name': n.name.trim(),
      'description': n.description.trim(),
      'category': n.category.trim(),
      'subcategory': n.subcategory.trim(),
      'brand': n.brand.trim(),
      'specifications': n.specifications.trim(),
      'unit': unit,
      'costPrice': double.tryParse(n.costPrice) ?? 0,
      'markupPercent': double.tryParse(n.markupPercent) ?? 0,
      'sellingPrice': double.tryParse(n.sellingPrice) ?? 0,
      'taxable': true,
      'supplier': '',
    };
  }

  Map<String, dynamic> _patchBody(NewProduct n) {
    final unit = n.unit.trim().isEmpty ? 'unit' : n.unit.trim();
    return {
      'itemCode': n.itemCode.trim(),
      'name': n.name.trim(),
      'description': n.description.trim(),
      'category': n.category.trim(),
      'subcategory': n.subcategory.trim(),
      'brand': n.brand.trim(),
      'specifications': n.specifications.trim(),
      'unit': unit,
      'costPrice': double.tryParse(n.costPrice) ?? 0,
      'markupPercent': double.tryParse(n.markupPercent) ?? 0,
      'sellingPrice': double.tryParse(n.sellingPrice) ?? 0,
    };
  }
}
