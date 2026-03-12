import '../repos/offline/products_schema.dart';

/// Product entity for the products table.
class ProductModel {
  const ProductModel({
    this.id,
    this.vendorId,
    this.name,
    this.nameEn,
    this.description,
    this.image,
    this.defaultPrice,
    this.hasVariants,
    this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int? vendorId;
  final String? name;
  final String? nameEn;
  final String? description;
  final String? image;
  final double? defaultPrice;
  final bool? hasVariants;
  final int? sortOrder;
  final String? createdAt;
  final String? updatedAt;

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map[ProductsSchema.colId] as int?,
      vendorId: map[ProductsSchema.colVendorId] as int?,
      name: map[ProductsSchema.colName] as String?,
      nameEn: map[ProductsSchema.colNameEn] as String?,
      description: map[ProductsSchema.colDescription] as String?,
      image: map[ProductsSchema.colImage] as String?,
      defaultPrice: (map[ProductsSchema.colDefaultPrice] as num?)?.toDouble(),
      hasVariants: (map[ProductsSchema.colHasVariants] as int?) == 1,
      sortOrder: map[ProductsSchema.colSortOrder] as int?,
      createdAt: map[ProductsSchema.colCreatedAt] as String?,
      updatedAt: map[ProductsSchema.colUpdatedAt] as String?,
    );
  }

  Map<String, dynamic> toInsertMap() {
    final now = DateTime.now().toIso8601String();
    return {
      ProductsSchema.colVendorId: vendorId,
      ProductsSchema.colName: name ?? '',
      ProductsSchema.colNameEn: nameEn,
      ProductsSchema.colDescription: description,
      ProductsSchema.colImage: image,
      ProductsSchema.colDefaultPrice: defaultPrice,
      ProductsSchema.colHasVariants: (hasVariants == true) ? 1 : 0,
      ProductsSchema.colSortOrder: sortOrder ?? 0,
      ProductsSchema.colCreatedAt: now,
      ProductsSchema.colUpdatedAt: now,
    };
  }
}
