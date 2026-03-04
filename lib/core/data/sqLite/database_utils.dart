import '../../core_repos/offline/roles/roles_schema.dart';
import '../../../../features/branches/repos/offline/branches_schema.dart';
import '../../../../features/users/repos/offline/users_schema.dart';
import '../../../../features/deliveries/repos/offline/deliveries_schema.dart';
import '../../../../features/zones/repos/offline/zones_schema.dart';

/// Central configuration for SQLite database.
/// Aggregates createTableStatements from core/feature models. Roles first, then users, branches, delivery_men, zones.
abstract class DatabaseUtils {
  DatabaseUtils._();

  static const String databaseName = 'eatic.db';
  static const int databaseVersion = 4;

  /// Run in order: roles, users, branches, delivery_men, zones (zones.branch_id references branches).
  static const List<String> createTableStatements = [
    RolesStatement.createTableRoles,
    UsersSchema.createTableUsers,
    BranchesSchema.createTableBranches,
    DeliveryMenSchema.createTableDeliveryMen,
    ZonesSchema.createTableZones,
  ];

  /// Run after createTableStatements in onCreate (e.g. seed default roles).
  static List<String> get seedStatements => RolesStatement.seedStatements;

  /// Migrations for existing DBs that were created before branches table existed.
  static List<String> get migrationFrom1To2 => [
        BranchesSchema.createTableBranches,
      ];

  /// Migrations for existing DBs that were created before delivery_men table existed.
  static List<String> get migrationFrom2To3 => [
        DeliveryMenSchema.createTableDeliveryMen,
      ];

  /// Migrations for existing DBs that were created before zones table existed.
  static List<String> get migrationFrom3To4 => [
        ZonesSchema.createTableZones,
      ];
}
