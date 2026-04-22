import '../../../zones/repos/offline/zones_schema.dart';

/// Schema for customers table (SQLite). id, phone, name, second_phone, created_at, updated_at.
abstract class CustomersSchema {
  CustomersSchema._();

  static const String tableCustomers = 'customers';

  static const String colId = 'id';
  static const String colPhone = 'phone';
  static const String colName = 'name';
  static const String colSecondPhone = 'second_phone';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  static const String createTableCustomers = '''
    CREATE TABLE $tableCustomers (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colPhone TEXT NOT NULL,
      $colName TEXT,
      $colSecondPhone TEXT,
      $colCreatedAt TEXT NOT NULL,
      $colUpdatedAt TEXT NOT NULL
    )
  ''';
}

/// Schema for customer_addresses table. One customer has many addresses.
abstract class CustomerAddressesSchema {
  CustomerAddressesSchema._();

  static const String tableCustomerAddresses = 'customer_addresses';

  static const String colId = 'id';
  static const String colCustomerId = 'customer_id';
  static const String colZoneId = 'zone_id';
  static const String colApartment = 'apartment';
  static const String colFloor = 'floor';
  static const String colBuildingNumber = 'building_number';
  static const String colIsDefault = 'is_default';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  static const String createTableCustomerAddresses = '''
    CREATE TABLE $tableCustomerAddresses (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colCustomerId INTEGER NOT NULL REFERENCES ${CustomersSchema.tableCustomers}(${CustomersSchema.colId}) ON DELETE CASCADE,
      $colZoneId INTEGER NOT NULL REFERENCES ${ZonesSchema.tableZones}(${ZonesSchema.colId}),
      $colApartment TEXT,
      $colFloor TEXT,
      $colBuildingNumber TEXT,
      $colIsDefault INTEGER NOT NULL DEFAULT 0,
      $colCreatedAt TEXT NOT NULL,
      $colUpdatedAt TEXT NOT NULL
    )
  ''';

  /// SQL for customer-address search (join customers, customer_addresses, zones).
  /// [whereClause] should be empty or start with "WHERE ".
  static String getCustomerAddressesSql(String whereClause) => '''
    SELECT
      c.${CustomersSchema.colId} AS customer_id,
      c.${CustomersSchema.colName} AS name,
      c.${CustomersSchema.colPhone} AS phone,
      c.${CustomersSchema.colSecondPhone} AS second_phone,
      a.${CustomerAddressesSchema.colZoneId} AS zone_id,
      z.${ZonesSchema.colName} AS zone_name,
      a.${CustomerAddressesSchema.colBuildingNumber} AS building_number,
      a.${CustomerAddressesSchema.colFloor} AS floor,
      a.${CustomerAddressesSchema.colApartment} AS apartment,
      a.${CustomerAddressesSchema.colId} AS address_id,
      a.${CustomerAddressesSchema.colIsDefault} AS is_default
    FROM ${CustomersSchema.tableCustomers} c
    INNER JOIN ${CustomerAddressesSchema.tableCustomerAddresses} a ON a.${CustomerAddressesSchema.colCustomerId} = c.${CustomersSchema.colId}
    INNER JOIN ${ZonesSchema.tableZones} z ON z.${ZonesSchema.colId} = a.${CustomerAddressesSchema.colZoneId}
    $whereClause
    ORDER BY c.${CustomersSchema.colId}, a.${CustomerAddressesSchema.colIsDefault} DESC, a.${CustomerAddressesSchema.colId}
  ''';
}
