import '../repos/offline/payment_methods_schema.dart';

/// Payment method entity matching the payment_methods table schema.
class PaymentMethodModel {
  const PaymentMethodModel({
    this.id,
    this.vendorId,
    this.name,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int? vendorId;
  final String? name;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;

  factory PaymentMethodModel.fromMap(Map<String, dynamic> map) {
    return PaymentMethodModel(
      id: map[PaymentMethodsSchema.colId] as int?,
      vendorId: map[PaymentMethodsSchema.colVendorId] as int?,
      name: map[PaymentMethodsSchema.colName] as String?,
      createdBy: map[PaymentMethodsSchema.colCreatedBy] as int?,
      createdAt: map[PaymentMethodsSchema.colCreatedAt] as String?,
      updatedAt: map[PaymentMethodsSchema.colUpdatedAt] as String?,
    );
  }

  Map<String, dynamic> toInsertMap() {
    final now = DateTime.now().toIso8601String();
    return {
      PaymentMethodsSchema.colVendorId: vendorId,
      PaymentMethodsSchema.colName: name ?? '',
      PaymentMethodsSchema.colCreatedBy: createdBy,
      PaymentMethodsSchema.colCreatedAt: now,
      PaymentMethodsSchema.colUpdatedAt: now,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    final now = DateTime.now().toIso8601String();
    return {
      PaymentMethodsSchema.colVendorId: vendorId,
      PaymentMethodsSchema.colName: name ?? '',
      PaymentMethodsSchema.colUpdatedAt: now,
    };
  }

  PaymentMethodModel copyWith({
    int? id,
    int? vendorId,
    String? name,
    int? createdBy,
    String? createdAt,
    String? updatedAt,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
