import '../repos/offline/restaurant_tables_schema.dart';

/// Restaurant table entity matching the restaurant_tables table schema.
/// branchName, diningAreaName, createdByName are resolved from JOINs (for display only).
class RestaurantTableModel {
  const RestaurantTableModel({
    this.id,
    this.branchId,
    this.diningAreaId,
    this.name,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.branchName,
    this.diningAreaName,
    this.createdByName,
  });

  final int? id;
  final int? branchId;
  final int? diningAreaId;
  final String? name;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;
  final String? branchName;
  final String? diningAreaName;
  final String? createdByName;

  factory RestaurantTableModel.fromMap(Map<String, dynamic> map) {
    return RestaurantTableModel(
      id: map[RestaurantTablesSchema.colId] as int?,
      branchId: map[RestaurantTablesSchema.colBranchId] as int?,
      diningAreaId: map[RestaurantTablesSchema.colDiningAreaId] as int?,
      name: map[RestaurantTablesSchema.colName] as String?,
      createdBy: map[RestaurantTablesSchema.colCreatedBy] as int?,
      createdAt: map[RestaurantTablesSchema.colCreatedAt] as String?,
      updatedAt: map[RestaurantTablesSchema.colUpdatedAt] as String?,
      branchName: map['branch_name'] as String?,
      diningAreaName: map['dining_area_name'] as String?,
      createdByName: map['created_by_name'] as String?,
    );
  }

  Map<String, dynamic> toInsertMap() {
    final now = DateTime.now().toIso8601String();
    return {
      RestaurantTablesSchema.colBranchId: branchId,
      RestaurantTablesSchema.colDiningAreaId: diningAreaId,
      RestaurantTablesSchema.colName: name ?? '',
      RestaurantTablesSchema.colCreatedBy: createdBy,
      RestaurantTablesSchema.colCreatedAt: now,
      RestaurantTablesSchema.colUpdatedAt: now,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    final now = DateTime.now().toIso8601String();
    return {
      RestaurantTablesSchema.colBranchId: branchId,
      RestaurantTablesSchema.colDiningAreaId: diningAreaId,
      RestaurantTablesSchema.colName: name ?? '',
      RestaurantTablesSchema.colUpdatedAt: now,
    };
  }

  RestaurantTableModel copyWith({
    int? id,
    int? branchId,
    int? diningAreaId,
    String? name,
    int? createdBy,
    String? createdAt,
    String? updatedAt,
    String? branchName,
    String? diningAreaName,
    String? createdByName,
  }) {
    return RestaurantTableModel(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      diningAreaId: diningAreaId ?? this.diningAreaId,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      branchName: branchName ?? this.branchName,
      diningAreaName: diningAreaName ?? this.diningAreaName,
      createdByName: createdByName ?? this.createdByName,
    );
  }
}
