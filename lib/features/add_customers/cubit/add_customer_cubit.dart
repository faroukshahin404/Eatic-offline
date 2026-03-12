import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/flutter_secure_storage.dart';
import '../model/address_model.dart';
import '../model/customer_model.dart';
import '../repos/offline/add_customers_offline_repos.dart';
import '../../zones/model/zone_model.dart';
import '../../zones/repos/offline/zones_offline_repos.dart';

part 'add_customer_state.dart';

/// Single address form entry: zone selection and text fields.
class AddressFormEntry {
  AddressFormEntry()
    : apartmentController = TextEditingController(),
      floorController = TextEditingController(),
      buildingNumberController = TextEditingController();

  ZoneModel? selectedZone;
  final TextEditingController apartmentController;
  final TextEditingController floorController;
  final TextEditingController buildingNumberController;
  bool isDefault = false;

  void dispose() {
    apartmentController.dispose();
    floorController.dispose();
    buildingNumberController.dispose();
  }
}

class AddCustomerCubit extends Cubit<AddCustomerState> {
  AddCustomerCubit(this._customersRepo, this._zonesRepo)
    : super(AddCustomerInitial());

  final AddCustomersOfflineRepository _customersRepo;
  final ZonesOfflineRepository _zonesRepo;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final secondPhoneController = TextEditingController();

  List<ZoneModel> zones = [];
  List<AddressFormEntry> addressEntries = [];

  Future<int?> _getUserBranchId() async {
    try {
      final jsonStr = await SecureLocalStorageService.readSecureData('user');
      if (jsonStr.isEmpty) return null;
      final map = jsonDecode(jsonStr) as Map<String, dynamic>?;
      if (map == null) return null;
      final branchId = map['branch_id'];
      if (branchId is int) return branchId;
      if (branchId is num) return branchId.toInt();
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> loadZones() async {
    emit(AddCustomerLoading());
    final branchId = await _getUserBranchId();
    if (branchId == null) {
      zones = [];
      _ensureOneAddress();
      emit(AddCustomerReady());
      return;
    }
    final result = await _zonesRepo.getZonesByBranchId(branchId);
    result.fold(
      (f) => emit(AddCustomerError(message: f.failureMessage ?? 'Error')),
      (list) {
        zones = list;
        _ensureOneAddress();
        emit(AddCustomerReady());
      },
    );
  }

  void _ensureOneAddress() {
    if (addressEntries.isEmpty) {
      addressEntries.add(AddressFormEntry());
    }
  }

  void addAddress() {
    addressEntries.add(AddressFormEntry());
    emit(AddCustomerReady());
  }

  void removeAddress(int index) {
    if (addressEntries.length <= 1) return;
    addressEntries[index].dispose();
    addressEntries.removeAt(index);
    emit(AddCustomerReady());
  }

  void setAddressZone(int index, ZoneModel? zone) {
    if (index < 0 || index >= addressEntries.length) return;
    addressEntries[index].selectedZone = zone;
    emit(AddCustomerReady());
  }

  void setAddressIsDefault(int index, bool value) {
    if (index < 0 || index >= addressEntries.length) return;
    if (value) {
      for (var i = 0; i < addressEntries.length; i++) {
        addressEntries[i].isDefault = i == index;
      }
    } else {
      addressEntries[index].isDefault = false;
    }
    emit(AddCustomerReady());
  }

  static bool _isNumber(String? value) {
    if (value == null || value.trim().isEmpty) return true;
    return int.tryParse(value.trim()) != null ||
        double.tryParse(value.trim()) != null;
  }

  /// For form validators (e.g. CustomTextField). Returns true if value is null/empty or a valid number.
  static bool isNumber(String? value) => _isNumber(value);

  String? validatePhones() {
    if (!_isNumber(phoneController.text)) return 'validation.phone_number'.tr();
    if (!_isNumber(secondPhoneController.text)) {
      return 'validation.phone_number'.tr();
    }
    return null;
  }

  String? validateAddresses() {
    if (addressEntries.isEmpty)
      return 'customers.validation.at_least_one_address'.tr();
    for (var i = 0; i < addressEntries.length; i++) {
      final e = addressEntries[i];
      if (e.selectedZone == null) {
        return 'customers.validation.zone_required'.tr();
      }
    }
    return null;
  }

  Future<void> save() async {
    if (formKey.currentState?.validate() != true) return;
    final phoneError = validatePhones();
    if (phoneError != null) {
      emit(AddCustomerError(message: phoneError));
      return;
    }
    final addressError = validateAddresses();
    if (addressError != null) {
      emit(AddCustomerError(message: addressError));
      return;
    }
    final phone = phoneController.text.trim();
    final name = nameController.text.trim();
    final secondPhone = secondPhoneController.text.trim();
    final addresses = addressEntries
        .where((e) => e.selectedZone != null)
        .map(
          (e) => AddressModel(
            zoneId: e.selectedZone!.id!,
            apartment: e.apartmentController.text.trim().isEmpty
                ? null
                : e.apartmentController.text.trim(),
            floor: e.floorController.text.trim().isEmpty
                ? null
                : e.floorController.text.trim(),
            buildingNumber: e.buildingNumberController.text.trim().isEmpty
                ? null
                : e.buildingNumberController.text.trim(),
            isDefault: e.isDefault,
          ),
        )
        .toList();
    if (addresses.isEmpty) {
      emit(
        AddCustomerError(
          message: 'customers.validation.at_least_one_address'.tr(),
        ),
      );
      return;
    }
    final customer = CustomerModel(
      phone: phone,
      name: name.isEmpty ? null : name,
      secondPhone: secondPhone.isEmpty ? null : secondPhone,
      addresses: addresses,
    );
    emit(AddCustomerLoading());
    final result = await _customersRepo.insert(customer);
    result.fold(
      (f) => emit(AddCustomerError(message: f.failureMessage ?? 'Error')),
      (_) => emit(AddCustomerSaved()),
    );
  }

  @override
  Future<void> close() {
    nameController.dispose();
    phoneController.dispose();
    secondPhoneController.dispose();
    for (final e in addressEntries) {
      e.dispose();
    }
    addressEntries.clear();
    return super.close();
  }
}
