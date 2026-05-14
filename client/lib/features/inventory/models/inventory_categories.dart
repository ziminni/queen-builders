import 'package:flutter/foundation.dart';

/// One catalog category with optional blurb for the Categories page.
@immutable
class InventoryCategoryDefinition {
  final String name;
  final String description;

  const InventoryCategoryDefinition({
    required this.name,
    required this.description,
  });
}

/// Source of truth for category names + descriptions (construction / builders supply context).
const List<InventoryCategoryDefinition> kInventoryCategoryDefinitions = [
  InventoryCategoryDefinition(
    name: 'Paint & Finishing',
    description:
        'Interior and exterior paints, primers, stains, clear coats, and prep for finished surfaces.',
  ),
  InventoryCategoryDefinition(
    name: 'Cement',
    description:
        'Bagged cement, mortar mixes, and binding materials for structural and masonry work.',
  ),
  InventoryCategoryDefinition(
    name: 'Aggregates',
    description:
        'Sand, gravel, crushed stone, and base materials for concrete, fill, and compaction.',
  ),
  InventoryCategoryDefinition(
    name: 'Steel',
    description:
        'Rebar, structural sections, mesh, and metal stock for reinforcement and framing.',
  ),
  InventoryCategoryDefinition(
    name: 'Wood',
    description:
        'Lumber, plywood, moulding, and engineered wood for formwork and carpentry.',
  ),
  InventoryCategoryDefinition(
    name: 'Nails & Fasteners',
    description:
        'Nails, screws, bolts, anchors, and hardware for joining and fixing assemblies.',
  ),
  InventoryCategoryDefinition(
    name: 'Blocks',
    description:
        'Concrete hollow blocks, pavers, and masonry units for walls and hardscape.',
  ),
  InventoryCategoryDefinition(
    name: 'Roofing',
    description:
        'Shingles, gutters, flashing, underlayment, and weatherproofing for roof systems.',
  ),
  InventoryCategoryDefinition(
    name: 'Electrical',
    description:
        'Wire, conduit, breakers, fixtures, and fittings for power and lighting rough-in.',
  ),
  InventoryCategoryDefinition(
    name: 'Plumbing',
    description:
        'Pipes, fittings, valves, fixtures, and drainage components for water and waste.',
  ),
  InventoryCategoryDefinition(
    name: 'Tools',
    description:
        'Hand tools, power tools, and jobsite equipment for cutting, fastening, and layout.',
  ),
  InventoryCategoryDefinition(
    name: 'Safety Equipment',
    description:
        'PPE, signage, harnesses, and site safety consumables for compliant work.',
  ),
];

/// Category labels used by inventory UI (matches filters; excludes "All").
final List<String> kInventoryProductCategories = List<String>.unmodifiable(
  kInventoryCategoryDefinitions.map((d) => d.name),
);

/// Description for [categoryName], or empty if unknown.
String inventoryCategoryDescription(String categoryName) {
  for (final d in kInventoryCategoryDefinitions) {
    if (d.name == categoryName) return d.description;
  }
  return '';
}
