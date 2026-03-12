import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/flutter_secure_storage.dart';
import '../model/customer_address_row.dart';
import '../repos/offline/customers_offline_repos.dart';

part 'customer_search_state.dart';

class CustomerSearchCubit extends Cubit<CustomerSearchState> {
  CustomerSearchCubit(this._repo) : super(CustomerSearchInitial());
  final CustomersOfflineRepository _repo;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  int? selectedAddressId;

  /// Loaded search results; set when state is CustomerSearchLoaded.
  List<CustomerAddressRow> rows = [];

  void setSelectedAddress(int? addressId) {
    selectedAddressId = addressId;
    if (state is CustomerSearchLoaded) emit(CustomerSearchLoaded());
  }

  /// Returns the row to use for "Add New Address" (selected row or first).
  CustomerAddressRow? get rowForNewAddress {
    if (rows.isEmpty) return null;
    if (selectedAddressId != null) {
      final match = rows.where((r) => r.addressId == selectedAddressId);
      if (match.isNotEmpty) return match.first;
    }
    return rows.first;
  }

  /// Deletes a customer and all their addresses; updates [rows] and state.
  Future<void> deleteCustomer(int customerId) async {
    final result = await _repo.deleteCustomer(customerId);
    result.fold(
      (f) => emit(CustomerSearchError(f.failureMessage ?? 'Error')),
      (_) {
        rows = rows.where((r) => r.customerId != customerId).toList();
        selectedAddressId = rows.any((r) => r.addressId == selectedAddressId)
            ? selectedAddressId
            : (rows.isNotEmpty ? rows.first.addressId : null);
        if (rows.isEmpty) {
          emit(CustomerSearchNoResults());
        } else {
          emit(CustomerSearchLoaded());
        }
      },
    );
  }

  /// Refreshes addresses for a customer and updates [rows] then emits.
  Future<void> refreshAfterAddAddress(int customerId) async {
    final result = await _repo.getCustomerById(customerId);
    result.fold(
      (_) {},
      (newRows) {
        if (state is CustomerSearchLoaded) {
          rows = rows
              .where((r) => r.customerId != customerId)
              .toList()
            ..addAll(newRows)
            ..sort((a, b) => a.customerId.compareTo(b.customerId));
          emit(CustomerSearchLoaded());
        }
      },
    );
  }

  @override
  Future<void> close() {
    nameController.dispose();
    phoneController.dispose();
    return super.close();
  }

  /// Runs search using current name and phone field values.
  Future<void> runSearch() =>
      search(name: nameController.text, phone: phoneController.text);

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

  /// Search by name and/or phone. When both are provided, both conditions are applied (AND).
  Future<void> search({String? name, String? phone}) async {
    final hasName = name != null && name.trim().isNotEmpty;
    final hasPhone = phone != null && phone.trim().isNotEmpty;

    emit(CustomerSearchLoading());
    final branchId = await _getUserBranchId();
    final result = await _repo.getCustomerAddresses(
      branchId: branchId,
      name: hasName ? name.trim() : null,
      phone: hasPhone ? phone.trim() : null,
    );
    result.fold((f) => emit(CustomerSearchError(f.failureMessage ?? 'Error')), (
      resultRows,
    ) {
      if (resultRows.isEmpty) {
        rows = [];
        selectedAddressId = null;
        emit(CustomerSearchNoResults());
      } else {
        rows = resultRows;
        selectedAddressId = resultRows.first.addressId;
        emit(CustomerSearchLoaded());
      }
    });
  }

  void clearResults() {
    rows = [];
    selectedAddressId = null;
    emit(CustomerSearchInitial());
  }
}
