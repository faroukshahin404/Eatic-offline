import '../repos/offline/deliveries_schema.dart';

/// Delivery man entity matching the delivery_men table schema.
class DeliveryModel {
  const DeliveryModel({
    this.id,
    this.vendorId,
    this.branchId,
    this.name,
    this.phone1,
    this.phone2,
    this.address,
    this.nationalId,
    this.createdAt,
    this.updatedAt,
    this.branchName,
  });

  final int? id;
  final int? vendorId;
  final int? branchId;
  final String? name;
  final String? phone1;
  final String? phone2;
  final String? address;
  final String? nationalId;
  final String? createdAt;
  final String? updatedAt;
  /// Resolved branch name from join by branch_id (for display only).
  final String? branchName;

  /// Display phone: phone_1, or phone_2 if phone_1 is null, or '-'.
  String get displayPhone => (phone1?.isNotEmpty == true)
      ? phone1!
      : (phone2?.isNotEmpty == true)
          ? phone2!
          : '-';

  factory DeliveryModel.fromMap(Map<String, dynamic> map) {
    return DeliveryModel(
      id: map[DeliveryMenSchema.colId] as int?,
      vendorId: map[DeliveryMenSchema.colVendorId] as int?,
      branchId: map[DeliveryMenSchema.colBranchId] as int?,
      name: map[DeliveryMenSchema.colName] as String?,
      phone1: map[DeliveryMenSchema.colPhone1] as String?,
      phone2: map[DeliveryMenSchema.colPhone2] as String?,
      address: map[DeliveryMenSchema.colAddress] as String?,
      nationalId: map[DeliveryMenSchema.colNationalId] as String?,
      createdAt: map[DeliveryMenSchema.colCreatedAt] as String?,
      updatedAt: map[DeliveryMenSchema.colUpdatedAt] as String?,
      branchName: map['branch_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (id != null) map[DeliveryMenSchema.colId] = id;
    if (vendorId != null) map[DeliveryMenSchema.colVendorId] = vendorId;
    if (branchId != null) map[DeliveryMenSchema.colBranchId] = branchId;
    if (name != null) map[DeliveryMenSchema.colName] = name;
    if (phone1 != null) map[DeliveryMenSchema.colPhone1] = phone1;
    if (phone2 != null) map[DeliveryMenSchema.colPhone2] = phone2;
    if (address != null) map[DeliveryMenSchema.colAddress] = address;
    if (nationalId != null) map[DeliveryMenSchema.colNationalId] = nationalId;
    if (createdAt != null) map[DeliveryMenSchema.colCreatedAt] = createdAt;
    if (updatedAt != null) map[DeliveryMenSchema.colUpdatedAt] = updatedAt;
    return map;
  }

  /// Map for insert (excludes id; includes branch_id and timestamps).
  Map<String, dynamic> toInsertMap() {
    final now = DateTime.now().toIso8601String();
    return {
      DeliveryMenSchema.colVendorId: vendorId,
      DeliveryMenSchema.colBranchId: branchId,
      DeliveryMenSchema.colName: name ?? '',
      DeliveryMenSchema.colPhone1: phone1,
      DeliveryMenSchema.colPhone2: phone2,
      DeliveryMenSchema.colAddress: address,
      DeliveryMenSchema.colNationalId: nationalId,
      DeliveryMenSchema.colCreatedAt: now,
      DeliveryMenSchema.colUpdatedAt: now,
    };
  }

  /// Map for update (excludes id and created_at; sets updated_at to now).
  Map<String, dynamic> toUpdateMap() {
    final now = DateTime.now().toIso8601String();
    return {
      DeliveryMenSchema.colVendorId: vendorId,
      DeliveryMenSchema.colBranchId: branchId,
      DeliveryMenSchema.colName: name ?? '',
      DeliveryMenSchema.colPhone1: phone1,
      DeliveryMenSchema.colPhone2: phone2,
      DeliveryMenSchema.colAddress: address,
      DeliveryMenSchema.colNationalId: nationalId,
      DeliveryMenSchema.colUpdatedAt: now,
    };
  }
}
