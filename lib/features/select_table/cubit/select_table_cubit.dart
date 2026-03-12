import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/flutter_secure_storage.dart';
import '../../restaurant_tables/model/restaurant_table_model.dart';
import '../../restaurant_tables/repos/offline/restaurant_tables_offline_repos.dart';

part 'select_table_state.dart';

class SelectTableCubit extends Cubit<SelectTableState> {
  SelectTableCubit(this._tablesRepo) : super(SelectTableInitial());

  final RestaurantTablesOfflineRepository _tablesRepo;

  List<RestaurantTableModel> tables = [];
  RestaurantTableModel? selectedTable;

  /// Reads user JSON from secure storage and returns branch_id, or null if missing/invalid.
  Future<int?> _getUserBranchId() async {
    try {
      final jsonStr =
          await SecureLocalStorageService.readSecureData('user');
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

  Future<void> loadTables() async {
    emit(SelectTableLoading());
    final branchId = await _getUserBranchId();
    final result = branchId != null
        ? await _tablesRepo.getByBranchId(branchId)
        : await _tablesRepo.getAll();
    result.fold(
      (f) => emit(SelectTableError(message: f.failureMessage ?? 'Error')),
      (list) {
        tables = list;
        emit(SelectTableLoaded());
      },
    );
  }

  void setSelectedTable(RestaurantTableModel? table) {
    selectedTable = table;
    emit(SelectTableLoaded());
  }
}
