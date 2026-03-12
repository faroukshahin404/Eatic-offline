import '../repos/offline/categories_schema.dart';

/// Category entity matching the categories table schema.
/// parentName is resolved from self-JOIN (for display only).
class CategoryModel {
  const CategoryModel({
    this.id,
    this.vendorId,
    this.name,
    this.parentId,
    this.createdAt,
    this.updatedAt,
    this.parentName,
  });

  final int? id;
  final int? vendorId;
  final String? name;
  final int? parentId;
  final String? createdAt;
  final String? updatedAt;
  final String? parentName;

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map[CategoriesSchema.colId] as int?,
      vendorId: map[CategoriesSchema.colVendorId] as int?,
      name: map[CategoriesSchema.colName] as String?,
      parentId: map[CategoriesSchema.colParentId] as int?,
      createdAt: map[CategoriesSchema.colCreatedAt] as String?,
      updatedAt: map[CategoriesSchema.colUpdatedAt] as String?,
      parentName: map['parent_name'] as String?,
    );
  }

  Map<String, dynamic> toInsertMap() {
    final now = DateTime.now().toIso8601String();
    return {
      CategoriesSchema.colVendorId: vendorId,
      CategoriesSchema.colName: name ?? '',
      CategoriesSchema.colParentId: parentId,
      CategoriesSchema.colCreatedAt: now,
      CategoriesSchema.colUpdatedAt: now,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    final now = DateTime.now().toIso8601String();
    return {
      CategoriesSchema.colVendorId: vendorId,
      CategoriesSchema.colName: name ?? '',
      CategoriesSchema.colParentId: parentId,
      CategoriesSchema.colUpdatedAt: now,
    };
  }

  CategoryModel copyWith({
    int? id,
    int? vendorId,
    String? name,
    int? parentId,
    String? createdAt,
    String? updatedAt,
    String? parentName,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parentName: parentName ?? this.parentName,
    );
  }
}
