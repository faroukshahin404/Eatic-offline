import '../../../../custody/repos/offline/custody_schema.dart';
import '../../../../customers/repos/offline/customers_schema.dart';
import '../../../../payment_methods/repos/offline/payment_methods_schema.dart';
import '../../../../price_lists/repos/offline/price_lists_schema.dart';
import '../../../../restaurant_tables/repos/offline/restaurant_tables_schema.dart';
import '../../../../users/repos/offline/users_schema.dart';

/// Schema for orders table (SQLite). Ties order to custody, cashier, optional waiter/table/customer/payment method.
abstract class OrdersSchema {
  OrdersSchema._();

  static const String tableOrders = 'orders';

  static const String colId = 'id';
  static const String colCustodyId = 'custody_id';
  static const String colCashierId = 'cashier_id';
  static const String colOrderType = 'order_type';
  static const String colTableId = 'table_id';
  static const String colTableNumber = 'table_number';
  static const String colWaiterId = 'waiter_id';
  static const String colCustomerId = 'customer_id';
  static const String colAddressId = 'address_id';
  static const String colPaymentMethodId = 'payment_method_id';
  static const String colSubtotal = 'subtotal';
  static const String colDiscountAmount = 'discount_amount';
  static const String colTotal = 'total';
  static const String colSelectedPriceListId = 'selected_price_list_id';
  static const String colCreatedAt = 'created_at';
  static const String colIsPending = 'is_pending';
  static const String colIsPrinted = 'is_printed';
  static const String colIsPrintedToCustomer = 'is_printed_to_customer';
  static const String colIsPrintedToKitchen = 'is_printed_to_kitchen';

  static const String createTableOrders = '''
    CREATE TABLE $tableOrders (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colSelectedPriceListId INTEGER NOT NULL REFERENCES ${PriceListsSchema.tablePriceLists}(${PriceListsSchema.colId}),
      $colCustodyId INTEGER NOT NULL REFERENCES ${CustodySchema.tableCustody}(${CustodySchema.colId}),
      $colCashierId INTEGER NOT NULL REFERENCES ${UsersSchema.tableUsers}(${UsersSchema.colId}),
      $colOrderType INTEGER NOT NULL,
      $colTableId INTEGER REFERENCES ${RestaurantTablesSchema.tableRestaurantTables}(${RestaurantTablesSchema.colId}),
      $colTableNumber TEXT,
      $colWaiterId INTEGER REFERENCES ${UsersSchema.tableUsers}(${UsersSchema.colId}),
      $colCustomerId INTEGER REFERENCES ${CustomersSchema.tableCustomers}(${CustomersSchema.colId}),
      $colAddressId INTEGER REFERENCES ${CustomerAddressesSchema.tableCustomerAddresses}(${CustomerAddressesSchema.colId}),
      $colPaymentMethodId INTEGER REFERENCES ${PaymentMethodsSchema.tablePaymentMethods}(${PaymentMethodsSchema.colId}),
      $colSubtotal REAL NOT NULL DEFAULT 0,
      $colDiscountAmount REAL NOT NULL DEFAULT 0,
      $colTotal REAL NOT NULL DEFAULT 0,
      $colCreatedAt TEXT,
      $colIsPending INTEGER NOT NULL DEFAULT 1,
      $colIsPrinted INTEGER NOT NULL DEFAULT 0,
      $colIsPrintedToCustomer INTEGER NOT NULL DEFAULT 0,
      $colIsPrintedToKitchen INTEGER NOT NULL DEFAULT 0
    )
  ''';
}

/// Schema for order_lines table (SQLite). One row per product line in an order.
abstract class OrderLinesSchema {
  OrderLinesSchema._();

  static const String tableOrderLines = 'order_lines';

  static const String colId = 'id';
  static const String colOrderId = 'order_id';
  static const String colProductId = 'product_id';
  static const String colProductName = 'product_name';
  static const String colVariantId = 'variant_id';
  static const String colVariantLabel = 'variant_label';
  static const String colPriceListId = 'price_list_id';
  static const String colUnitPrice = 'unit_price';
  static const String colQuantity = 'quantity';
  static const String colAddonsTotal = 'addons_total';
  static const String colLineTotal = 'line_total';
  static const String colNotes = 'notes';

  static const String createTableOrderLines = '''
    CREATE TABLE $tableOrderLines (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colOrderId INTEGER NOT NULL REFERENCES ${OrdersSchema.tableOrders}(${OrdersSchema.colId}) ON DELETE CASCADE,
      $colProductId INTEGER NOT NULL,
      $colProductName TEXT,
      $colVariantId INTEGER,
      $colVariantLabel TEXT,
      $colPriceListId INTEGER,
      $colUnitPrice REAL NOT NULL DEFAULT 0,
      $colQuantity INTEGER NOT NULL DEFAULT 1,
      $colAddonsTotal REAL NOT NULL DEFAULT 0,
      $colLineTotal REAL NOT NULL DEFAULT 0,
      $colNotes TEXT
    )
  ''';
}

abstract class OrderTypesSchema {
  OrderTypesSchema._();

  static const String tableOrderTypes = 'order_types';

  static const String colId = 'id';
  static const String colName = 'name';

  static const String createTableOrderTypes = '''
    CREATE TABLE $tableOrderTypes (
      $colId INTEGER PRIMARY KEY,
      $colName TEXT NOT NULL
    )
  ''';

  static const List<String> seedStatements = [
    "INSERT INTO $tableOrderTypes ($colId, $colName) VALUES (0, 'hall')",
    "INSERT INTO $tableOrderTypes ($colId, $colName) VALUES (1, 'takeaway')",
    "INSERT INTO $tableOrderTypes ($colId, $colName) VALUES (2, 'delivery')",
  ];
}
