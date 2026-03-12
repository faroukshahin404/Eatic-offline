import '../repos/offline/zones_schema.dart';

/// Zone entity matching the zones table schema.
class ZoneModel {
  const ZoneModel({
    this.id,
    this.vendorId,
    this.branchId,
    this.name,
    this.deliveryCharge,
    this.createdAt,
    this.updatedAt,
    this.branchName,
  });

  final int? id;
  final int? vendorId;
  final int? branchId;
  final String? name;
  final double? deliveryCharge;
  final String? createdAt;
  final String? updatedAt;
  /// Resolved branch name from join by branch_id (for display only).
  final String? branchName;

  factory ZoneModel.fromMap(Map<String, dynamic> map) {
    return ZoneModel(
      id: map[ZonesSchema.colId] as int?,
      vendorId: map[ZonesSchema.colVendorId] as int?,
      branchId: map[ZonesSchema.colBranchId] as int?,
      name: map[ZonesSchema.colName] as String?,
      deliveryCharge: (map[ZonesSchema.colDeliveryCharge] as num?)?.toDouble(),
      createdAt: map[ZonesSchema.colCreatedAt] as String?,
      updatedAt: map[ZonesSchema.colUpdatedAt] as String?,
      branchName: map['branch_name'] as String?,
    );
  }

  /// Map for insert (excludes id; includes branch_id, delivery_charge, timestamps).
  Map<String, dynamic> toInsertMap() {
    final now = DateTime.now().toIso8601String();
    return {
      ZonesSchema.colVendorId: vendorId,
      ZonesSchema.colBranchId: branchId,
      ZonesSchema.colName: name ?? '',
      ZonesSchema.colDeliveryCharge: (deliveryCharge ?? 0).toDouble(),
      ZonesSchema.colCreatedAt: now,
      ZonesSchema.colUpdatedAt: now,
    };
  }

  /// Map for update (excludes id and created_at; sets updated_at to now).
  Map<String, dynamic> toUpdateMap() {
    final now = DateTime.now().toIso8601String();
    return {
      ZonesSchema.colVendorId: vendorId,
      ZonesSchema.colBranchId: branchId,
      ZonesSchema.colName: name ?? '',
      ZonesSchema.colDeliveryCharge: (deliveryCharge ?? 0).toDouble(),
      ZonesSchema.colUpdatedAt: now,
    };
  }
}
