import '../../../branches/repos/offline/branches_schema.dart';
import '../../../zones/repos/offline/zones_schema.dart';

/// SQL and schema constants for add_new_zone offline repo (e.g. get zone by id query).
abstract class AddNewZoneOfflineSchema {
  AddNewZoneOfflineSchema._();

  /// Raw SQL to fetch a single zone by id with branch name. Use with whereArgs: [id].
  static const String sqlGetZoneById = '''
    SELECT z.${ZonesSchema.colId}, z.${ZonesSchema.colVendorId},
           z.${ZonesSchema.colBranchId}, z.${ZonesSchema.colName},
           z.${ZonesSchema.colDeliveryCharge}, z.${ZonesSchema.colCreatedAt},
           z.${ZonesSchema.colUpdatedAt},
           b.${BranchesSchema.colName} AS branch_name
    FROM ${ZonesSchema.tableZones} z
    LEFT JOIN ${BranchesSchema.tableBranches} b ON z.${ZonesSchema.colBranchId} = b.${BranchesSchema.colId}
    WHERE z.${ZonesSchema.colId} = ?
  ''';
}
