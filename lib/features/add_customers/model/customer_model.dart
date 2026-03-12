import 'address_model.dart';
import '../../customers/repos/offline/customers_schema.dart';

/// Customer entity: phone, name, second_phone, and a list of addresses.
class CustomerModel {
  const CustomerModel({
    this.id,
    required this.phone,
    this.name,
    this.secondPhone,
    this.createdAt,
    this.updatedAt,
    this.addresses = const [],
  });

  final int? id;
  final String phone;
  final String? name;
  final String? secondPhone;
  final String? createdAt;
  final String? updatedAt;
  final List<AddressModel> addresses;

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map[CustomersSchema.colId] as int?,
      phone: map[CustomersSchema.colPhone] as String,
      name: map[CustomersSchema.colName] as String?,
      secondPhone: map[CustomersSchema.colSecondPhone] as String?,
      createdAt: map[CustomersSchema.colCreatedAt] as String?,
      updatedAt: map[CustomersSchema.colUpdatedAt] as String?,
      addresses: const [],
    );
  }

  Map<String, dynamic> toInsertMap(String now) {
    return {
      CustomersSchema.colPhone: phone,
      CustomersSchema.colName: name,
      CustomersSchema.colSecondPhone: secondPhone,
      CustomersSchema.colCreatedAt: now,
      CustomersSchema.colUpdatedAt: now,
    };
  }

  Map<String, dynamic> toUpdateMap(String now) {
    return {
      CustomersSchema.colPhone: phone,
      CustomersSchema.colName: name,
      CustomersSchema.colSecondPhone: secondPhone,
      CustomersSchema.colUpdatedAt: now,
    };
  }

  CustomerModel copyWith({
    int? id,
    String? phone,
    String? name,
    String? secondPhone,
    String? createdAt,
    String? updatedAt,
    List<AddressModel>? addresses,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      secondPhone: secondPhone ?? this.secondPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      addresses: addresses ?? this.addresses,
    );
  }
}
