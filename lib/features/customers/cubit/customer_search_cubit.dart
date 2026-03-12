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
      rows,
    ) {
      if (rows.isEmpty) {
        emit(CustomerSearchNoResults());
      } else {
        emit(CustomerSearchLoaded(rows));
      }
    });
  }

  void clearResults() {
    emit(CustomerSearchInitial());
  }
}
