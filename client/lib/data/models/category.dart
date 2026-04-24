class Category {
  final String name;
  final List<String> subcategories;
  final double typicalMarkupMin;
  final double typicalMarkupMax;
  final String? locationPrefix;
  final String? description;

  const Category({
    required this.name,
    required this.subcategories,
    required this.typicalMarkupMin,
    required this.typicalMarkupMax,
    this.locationPrefix,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] as String,
      subcategories: (json['subcategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      typicalMarkupMin: (json['typicalMarkupMin'] as num).toDouble(),
      typicalMarkupMax: (json['typicalMarkupMax'] as num).toDouble(),
      locationPrefix: json['locationPrefix'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'subcategories': subcategories,
      'typicalMarkupMin': typicalMarkupMin,
      'typicalMarkupMax': typicalMarkupMax,
      'locationPrefix': locationPrefix,
      'description': description,
    };
  }
}

/// Predefined categories for Queen Builders inventory
class Categories {
  static const List<String> all = [
    'All Categories',
    'Paint & Finishing',
    'Cement',
    'Aggregates',
    'Steel',
    'Wood',
    'Nails & Fasteners',
    'Blocks',
    'Roofing',
    'Electrical',
    'Plumbing',
    'Tools',
    'Safety Equipment',
  ];

  static final Map<String, Category> categories = {
    'Paint & Finishing': const Category(
      name: 'Paint & Finishing',
      subcategories: ['Interior Paint', 'Exterior Paint', 'Primer', 'Thinner', 'Brushes & Rollers'],
      typicalMarkupMin: 25,
      typicalMarkupMax: 30,
      locationPrefix: 'Aisle 1',
      description: 'Paints, coatings, and painting accessories',
    ),
    'Cement': const Category(
      name: 'Cement',
      subcategories: ['Portland Cement', 'Masonry Cement', 'White Cement'],
      typicalMarkupMin: 20,
      typicalMarkupMax: 25,
      locationPrefix: 'Zone A',
      description: 'Cement products for construction',
    ),
    'Aggregates': const Category(
      name: 'Aggregates',
      subcategories: ['Sand', 'Gravel', 'Crushed Stone'],
      typicalMarkupMin: 20,
      typicalMarkupMax: 26,
      locationPrefix: 'Outdoor',
      description: 'Sand, gravel, and other aggregates',
    ),
    'Steel': const Category(
      name: 'Steel',
      subcategories: ['Rebar', 'Wire', 'Angle Bar', 'Square Tubing'],
      typicalMarkupMin: 20,
      typicalMarkupMax: 22,
      locationPrefix: 'Zone B',
      description: 'Steel and metal products',
    ),
    'Wood': const Category(
      name: 'Wood',
      subcategories: ['Lumber', 'Plywood', 'Lawanit', 'Hardwood'],
      typicalMarkupMin: 30,
      typicalMarkupMax: 35,
      locationPrefix: 'Zone C',
      description: 'Wood and lumber products',
    ),
    'Nails & Fasteners': const Category(
      name: 'Nails & Fasteners',
      subcategories: ['Common Nails', 'Screws', 'Bolts & Nuts', 'Anchors'],
      typicalMarkupMin: 25,
      typicalMarkupMax: 35,
      locationPrefix: 'Aisle 2',
      description: 'Nails, screws, and fastening hardware',
    ),
    'Blocks': const Category(
      name: 'Blocks',
      subcategories: ['Hollow Blocks', 'Solid Blocks', 'Interlocking Blocks'],
      typicalMarkupMin: 25,
      typicalMarkupMax: 25,
      locationPrefix: 'Outdoor',
      description: 'Concrete blocks for construction',
    ),
    'Roofing': const Category(
      name: 'Roofing',
      subcategories: ['GI Sheets', 'Pre-painted Sheets', 'Asphalt Shingles', 'Accessories'],
      typicalMarkupMin: 24,
      typicalMarkupMax: 28,
      locationPrefix: 'Zone D',
      description: 'Roofing materials and accessories',
    ),
    'Electrical': const Category(
      name: 'Electrical',
      subcategories: ['Wires', 'Conduits', 'Outlets & Switches', 'Circuit Breakers', 'Lighting'],
      typicalMarkupMin: 22,
      typicalMarkupMax: 32,
      locationPrefix: 'Aisle 4',
      description: 'Electrical supplies and components',
    ),
    'Plumbing': const Category(
      name: 'Plumbing',
      subcategories: ['PVC Pipes', 'PVC Fittings', 'GI Pipes', 'Faucets', 'Valves'],
      typicalMarkupMin: 28,
      typicalMarkupMax: 35,
      locationPrefix: 'Aisle 5',
      description: 'Plumbing supplies and fixtures',
    ),
    'Tools': const Category(
      name: 'Tools',
      subcategories: ['Hand Tools', 'Power Tools', 'Measuring Tools', 'Garden Tools'],
      typicalMarkupMin: 30,
      typicalMarkupMax: 32,
      locationPrefix: 'Aisle 6',
      description: 'Hand and power tools',
    ),
    'Safety Equipment': const Category(
      name: 'Safety Equipment',
      subcategories: ['Gloves', 'Head Protection', 'Eye Protection', 'Footwear', 'Vests'],
      typicalMarkupMin: 28,
      typicalMarkupMax: 32,
      locationPrefix: 'Aisle 7',
      description: 'Personal protective equipment',
    ),
  };
}
