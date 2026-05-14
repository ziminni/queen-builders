/// Payload from the Add Product dialog: catalog registration only.
/// Stock and supplier are handled via receive delivery workflow.
class NewProduct {
  String itemCode;
  String name;
  String description;
  String brand;
  String category;
  String subcategory;
  String specifications;
  String unit;
  String costPrice;
  String markupPercent;
  String sellingPrice;

  NewProduct({
    this.itemCode = '',
    this.name = '',
    this.description = '',
    this.brand = '',
    this.category = '',
    this.subcategory = '',
    this.specifications = '',
    this.unit = '',
    this.costPrice = '',
    this.markupPercent = '',
    this.sellingPrice = '',
  });
}
