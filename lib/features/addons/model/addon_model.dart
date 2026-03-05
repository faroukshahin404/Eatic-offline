import '../repos/offline/addons_schema.dart';

/// Addon entity matching the addons table schema.
class AddonModel {
  const AddonModel({
    this.id,
    this.vendorId,
    this.name,
    this.defaultPrice,
    this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int? vendorId;
  final String? name;
  final double? defaultPrice;
  final int? sortOrder;
  final String? createdAt;
  final String? updatedAt;

  factory AddonModel.fromMap(Map<String, dynamic> map) {
    return AddonModel(
      id: map[AddonsSchema.colId] as int?,
      vendorId: map[AddonsSchema.colVendorId] as int?,
      name: map[AddonsSchema.colName] as String?,
      defaultPrice: (map[AddonsSchema.colDefaultPrice] as num?)?.toDouble(),
      sortOrder: map[AddonsSchema.colSortOrder] as int?,
      createdAt: map[AddonsSchema.colCreatedAt] as String?,
      updatedAt: map[AddonsSchema.colUpdatedAt] as String?,
    );
  }

  Map<String, dynamic> toInsertMap() {
    final now = DateTime.now().toIso8601String();
    return {
      AddonsSchema.colVendorId: vendorId,
      AddonsSchema.colName: name ?? '',
      AddonsSchema.colDefaultPrice: defaultPrice,
      AddonsSchema.colSortOrder: sortOrder ?? 0,
      AddonsSchema.colCreatedAt: now,
      AddonsSchema.colUpdatedAt: now,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    final now = DateTime.now().toIso8601String();
    return {
      AddonsSchema.colVendorId: vendorId,
      AddonsSchema.colName: name ?? '',
      AddonsSchema.colDefaultPrice: defaultPrice,
      AddonsSchema.colSortOrder: sortOrder ?? 0,
      AddonsSchema.colUpdatedAt: now,
    };
  }

  AddonModel copyWith({
    int? id,
    int? vendorId,
    String? name,
    double? defaultPrice,
    int? sortOrder,
    String? createdAt,
    String? updatedAt,
  }) {
    return AddonModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      defaultPrice: defaultPrice ?? this.defaultPrice,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
