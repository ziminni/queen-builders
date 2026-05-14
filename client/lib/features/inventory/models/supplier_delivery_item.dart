/// Single product line on a supplier delivery receipt (inventory workflow).
class SupplierDeliveryItem {
  int productId;
  int quantity;

  SupplierDeliveryItem({
    required this.productId,
    required this.quantity,
  });
}
