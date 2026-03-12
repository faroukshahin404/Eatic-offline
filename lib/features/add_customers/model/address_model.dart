import '../../customers/repos/offline/customers_schema.dart';

/// Single address for a customer (zone, apartment, floor, building_number, is_default).
class AddressModel {
  const AddressModel({
    this.id,
    this.customerId,
    required this.zoneId,
    this.apartment,
    this.floor,
    this.buildingNumber,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int? customerId;
  final int zoneId;
  final String? apartment;
  final String? floor;
  final String? buildingNumber;
  final bool isDefault;
  final String? createdAt;
  final String? updatedAt;

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    final isDefaultRaw = map[CustomerAddressesSchema.colIsDefault];
    final isDefault = isDefaultRaw == 1 || isDefaultRaw == true;
    return AddressModel(
      id: map[CustomerAddressesSchema.colId] as int?,
      customerId: map[CustomerAddressesSchema.colCustomerId] as int?,
      zoneId: map[CustomerAddressesSchema.colZoneId] as int,
      apartment: map[CustomerAddressesSchema.colApartment] as String?,
      floor: map[CustomerAddressesSchema.colFloor] as String?,
      buildingNumber: map[CustomerAddressesSchema.colBuildingNumber] as String?,
      isDefault: isDefault,
      createdAt: map[CustomerAddressesSchema.colCreatedAt] as String?,
      updatedAt: map[CustomerAddressesSchema.colUpdatedAt] as String?,
    );
  }

  Map<String, dynamic> toInsertMap({required int customerId, required String now}) {
    return {
      CustomerAddressesSchema.colCustomerId: customerId,
      CustomerAddressesSchema.colZoneId: zoneId,
      CustomerAddressesSchema.colApartment: apartment,
      CustomerAddressesSchema.colFloor: floor,
      CustomerAddressesSchema.colBuildingNumber: buildingNumber,
      CustomerAddressesSchema.colIsDefault: isDefault ? 1 : 0,
      CustomerAddressesSchema.colCreatedAt: now,
      CustomerAddressesSchema.colUpdatedAt: now,
    };
  }

  AddressModel copyWith({
    int? id,
    int? customerId,
    int? zoneId,
    String? apartment,
    String? floor,
    String? buildingNumber,
    bool? isDefault,
    String? createdAt,
    String? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      zoneId: zoneId ?? this.zoneId,
      apartment: apartment ?? this.apartment,
      floor: floor ?? this.floor,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
