/// One row for the customer-address search table: customer info + one address.
class CustomerAddressRow {
  const CustomerAddressRow({
    required this.customerId,
    required this.name,
    required this.phone,
    this.secondPhone,
    required this.zoneId,
    required this.zoneName,
    this.buildingNumber,
    this.floor,
    this.apartment,
    required this.addressId,
    required this.isDefault,
  });

  final int customerId;
  final String? name;
  final String phone;
  final String? secondPhone;
  final int zoneId;
  final String zoneName;
  final String? buildingNumber;
  final String? floor;
  final String? apartment;
  final int addressId;
  final bool isDefault;

  factory CustomerAddressRow.fromMap(Map<String, dynamic> map) {
    final isDefaultRaw = map['is_default'];
    final isDefault = isDefaultRaw == 1 || isDefaultRaw == true;
    return CustomerAddressRow(
      customerId: _readInt(map, 'customer_id'),
      name: map['name'] as String?,
      phone: (map['phone'] ?? '').toString(),
      secondPhone: map['second_phone'] as String?,
      zoneId: _readInt(map, 'zone_id'),
      zoneName: (map['zone_name'] ?? '').toString(),
      buildingNumber: map['building_number'] as String?,
      floor: map['floor'] as String?,
      apartment: map['apartment'] as String?,
      addressId: _readInt(map, 'address_id'),
      isDefault: isDefault,
    );
  }

  static int _readInt(Map<String, dynamic> map, String key) {
    final v = map[key];
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}
