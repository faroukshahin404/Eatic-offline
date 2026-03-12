import '../../users/model/user_model.dart';
import '../repos/offline/branches_schema.dart';

/// Branch entity matching the branches table schema.
class BranchModel {
  const BranchModel({
    this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
    this.vendorId,
    this.createdBy,
  });

  final int? id;
  final String name;
  final String? createdAt;
  final String? updatedAt;
  final int? vendorId;
  final UserModel? createdBy;

  factory BranchModel.fromMap(Map<String, dynamic> map) {
    UserModel? createdByUser;
    final createdByData = map['created_by_user'];
    if (createdByData is Map<String, dynamic>) {
      createdByUser = UserModel.fromMap(createdByData);
    }
    return BranchModel(
      id: map[BranchesSchema.colId] as int?,
      name: map[BranchesSchema.colName] as String,
      createdAt: map[BranchesSchema.colCreatedAt] as String?,
      updatedAt: map[BranchesSchema.colUpdatedAt] as String?,
      vendorId: map[BranchesSchema.colVendorId] as int?,
      createdBy: createdByUser,
    );
  }

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    UserModel? createdByUser;
    final createdByData = json['created_by'];
    if (createdByData is Map<String, dynamic>) {
      createdByUser = UserModel.fromJson(createdByData);
    }
    return BranchModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      vendorId: json['vendor_id'] as int?,
      createdBy: createdByUser,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'vendor_id': vendorId,
        if (createdBy != null) 'created_by': createdBy!.id,
      };

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{BranchesSchema.colName: name};
    if (id != null) map[BranchesSchema.colId] = id;
    if (createdAt != null) map[BranchesSchema.colCreatedAt] = createdAt;
    if (updatedAt != null) map[BranchesSchema.colUpdatedAt] = updatedAt;
    if (vendorId != null) map[BranchesSchema.colVendorId] = vendorId;
    if (createdBy?.id != null) map[BranchesSchema.colCreatedBy] = createdBy!.id;
    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return {
      BranchesSchema.colName: name,
      BranchesSchema.colCreatedAt: createdAt,
      BranchesSchema.colUpdatedAt: updatedAt,
      BranchesSchema.colVendorId: vendorId,
      BranchesSchema.colCreatedBy: createdBy?.id,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      BranchesSchema.colName: name,
      BranchesSchema.colUpdatedAt: updatedAt,
      BranchesSchema.colVendorId: vendorId,
      BranchesSchema.colCreatedBy: createdBy?.id,
    };
  }

  BranchModel copyWith({
    int? id,
    String? name,
    String? createdAt,
    String? updatedAt,
    int? vendorId,
    UserModel? createdBy,
  }) {
    return BranchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      vendorId: vendorId ?? this.vendorId,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
