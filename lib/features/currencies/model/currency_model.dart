import '../repos/offline/currencies_schema.dart';

/// Currency entity matching the currencies table schema.
class CurrencyModel {
  const CurrencyModel({
    this.id,
    this.vendorId,
    this.name,
    this.code,
    this.symbol,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int? vendorId;
  final String? name;
  final String? code;
  final String? symbol;
  final String? createdAt;
  final String? updatedAt;

  factory CurrencyModel.fromMap(Map<String, dynamic> map) {
    return CurrencyModel(
      id: map[CurrenciesSchema.colId] as int?,
      vendorId: map[CurrenciesSchema.colVendorId] as int?,
      name: map[CurrenciesSchema.colName] as String?,
      code: map[CurrenciesSchema.colCode] as String?,
      symbol: map[CurrenciesSchema.colSymbol] as String?,
      createdAt: map[CurrenciesSchema.colCreatedAt] as String?,
      updatedAt: map[CurrenciesSchema.colUpdatedAt] as String?,
    );
  }

  Map<String, dynamic> toInsertMap() {
    final now = DateTime.now().toIso8601String();
    return {
      CurrenciesSchema.colVendorId: vendorId,
      CurrenciesSchema.colName: name ?? '',
      CurrenciesSchema.colCode: code ?? '',
      CurrenciesSchema.colSymbol: symbol,
      CurrenciesSchema.colCreatedAt: now,
      CurrenciesSchema.colUpdatedAt: now,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    final now = DateTime.now().toIso8601String();
    return {
      CurrenciesSchema.colVendorId: vendorId,
      CurrenciesSchema.colName: name ?? '',
      CurrenciesSchema.colCode: code ?? '',
      CurrenciesSchema.colSymbol: symbol,
      CurrenciesSchema.colUpdatedAt: now,
    };
  }
}
