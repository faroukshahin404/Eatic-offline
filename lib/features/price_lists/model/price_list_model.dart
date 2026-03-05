import '../repos/offline/price_lists_schema.dart';

/// Price list entity matching the price_lists table schema.
/// currencyName is resolved from JOIN with currencies (for display only).
class PriceListModel {
  const PriceListModel({
    this.id,
    this.vendorId,
    this.currencyId,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.currencyName,
  });

  final int? id;
  final int? vendorId;
  final int? currencyId;
  final String? name;
  final String? createdAt;
  final String? updatedAt;
  final String? currencyName;

  factory PriceListModel.fromMap(Map<String, dynamic> map) {
    return PriceListModel(
      id: map[PriceListsSchema.colId] as int?,
      vendorId: map[PriceListsSchema.colVendorId] as int?,
      currencyId: map[PriceListsSchema.colCurrencyId] as int?,
      name: map[PriceListsSchema.colName] as String?,
      createdAt: map[PriceListsSchema.colCreatedAt] as String?,
      updatedAt: map[PriceListsSchema.colUpdatedAt] as String?,
      currencyName: map['currency_name'] as String?,
    );
  }

  Map<String, dynamic> toInsertMap() {
    final now = DateTime.now().toIso8601String();
    return {
      PriceListsSchema.colVendorId: vendorId,
      PriceListsSchema.colCurrencyId: currencyId,
      PriceListsSchema.colName: name ?? '',
      PriceListsSchema.colCreatedAt: now,
      PriceListsSchema.colUpdatedAt: now,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    final now = DateTime.now().toIso8601String();
    return {
      PriceListsSchema.colVendorId: vendorId,
      PriceListsSchema.colCurrencyId: currencyId,
      PriceListsSchema.colName: name ?? '',
      PriceListsSchema.colUpdatedAt: now,
    };
  }

  PriceListModel copyWith({
    int? id,
    int? vendorId,
    int? currencyId,
    String? name,
    String? createdAt,
    String? updatedAt,
    String? currencyName,
  }) {
    return PriceListModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      currencyId: currencyId ?? this.currencyId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currencyName: currencyName ?? this.currencyName,
    );
  }
}
