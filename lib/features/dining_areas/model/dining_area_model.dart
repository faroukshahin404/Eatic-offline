import '../repos/offline/dining_areas_schema.dart';

/// Dining area entity matching the dining_areas table schema.
/// branchName is resolved from JOIN with branches (for display only).
class DiningAreaModel {
  const DiningAreaModel({
    this.id,
    this.vendorId,
    this.branchId,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.branchName,
  });

  final int? id;
  final int? vendorId;
  final int? branchId;
  final String? name;
  final String? createdAt;
  final String? updatedAt;
  final String? branchName;

  factory DiningAreaModel.fromMap(Map<String, dynamic> map) {
    return DiningAreaModel(
      id: map[DiningAreasSchema.colId] as int?,
      vendorId: map[DiningAreasSchema.colVendorId] as int?,
      branchId: map[DiningAreasSchema.colBranchId] as int?,
      name: map[DiningAreasSchema.colName] as String?,
      createdAt: map[DiningAreasSchema.colCreatedAt] as String?,
      updatedAt: map[DiningAreasSchema.colUpdatedAt] as String?,
      branchName: map['branch_name'] as String?,
    );
  }

  Map<String, dynamic> toInsertMap() {
    final now = DateTime.now().toIso8601String();
    return {
      DiningAreasSchema.colVendorId: vendorId,
      DiningAreasSchema.colBranchId: branchId,
      DiningAreasSchema.colName: name ?? '',
      DiningAreasSchema.colCreatedAt: now,
      DiningAreasSchema.colUpdatedAt: now,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    final now = DateTime.now().toIso8601String();
    return {
      DiningAreasSchema.colVendorId: vendorId,
      DiningAreasSchema.colBranchId: branchId,
      DiningAreasSchema.colName: name ?? '',
      DiningAreasSchema.colUpdatedAt: now,
    };
  }

  DiningAreaModel copyWith({
    int? id,
    int? vendorId,
    int? branchId,
    String? name,
    String? createdAt,
    String? updatedAt,
    String? branchName,
  }) {
    return DiningAreaModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      branchId: branchId ?? this.branchId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      branchName: branchName ?? this.branchName,
    );
  }
}
