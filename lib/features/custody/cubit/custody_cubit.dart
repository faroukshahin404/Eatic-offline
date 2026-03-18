import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/flutter_secure_storage.dart';
import '../../users/model/user_model.dart';
import '../../users/session_user_holder.dart';
import '../model/custody_model.dart';
import '../repos/offline/custody_offline_repos.dart';
import 'custody_state.dart';

class CustodyCubit extends Cubit<CustodyState> {
  CustodyCubit(this._repo) : super(CustodyInitial());

  final CustodyOfflineRepository _repo;

  Future<CustodyModel?> getById(int id) async {
    final result = await _repo.getById(id);
    return result.fold((_) => null, (v) => v);
  }

  /// Current user for createdBy/closedBy. Tries secure storage first, then session holder (e.g. when keychain write failed).
  Future<UserModel?> getStoredUser() async {
    try {
      final userJson = await SecureLocalStorageService.readSecureData('user');
      if (userJson.isNotEmpty) {
        final decoded = jsonDecode(userJson);
        if (decoded is Map<String, dynamic>) {
          final user = UserModel.fromJson(decoded);
          SessionUserHolder.current = user;
          return user;
        }
      }
    } catch (_) {}
    return SessionUserHolder.current;
  }

  /// Creates a new custody with [totalWhenCreate]. Saves current user id as createdBy.
  Future<CustodyModel?> addNew({
    required double totalWhenCreate,
  }) async {
    final user = await getStoredUser();
    final custody = CustodyModel(
      totalWhenCreate: totalWhenCreate,
      createdAt: DateTime.now().toIso8601String(),
      createdBy: user?.id,
      isClosed: false,
    );
    final result = await _repo.add(custody);
    return result.fold((_) => null, (v) {
      emit(CustodyCreateSuccess(v));
      return v;
    });
  }

  /// Call after handling [CustodyCreateSuccess] to reset state.
  void restoreAfterCreate() {
    emit(CustodyInitial());
  }

  Future<bool> updateCustody(CustodyModel custody) async {
    final result = await _repo.update(custody);
    return result.fold((_) => false, (_) => true);
  }

  /// Closes the last opened custody (most recent open one). Saves current user id as closedBy. Returns false if none open.
  Future<bool> closeCustody(double totalWhenClose) async {
    final user = await getStoredUser();
    final result = await _repo.getLastOpenCustody();
    final existing = result.fold((_) => null, (v) => v);
    if (existing == null || existing.id == null) return false;
    final updated = existing.copyWith(
      isClosed: true,
      closedBy: user?.id,
      totalWhenClose: totalWhenClose,
    );
    final ok = await updateCustody(updated);
    if (ok) emit(CustodyCloseSuccess());
    return ok;
  }

  /// Call after handling [CustodyCloseSuccess] to reset state.
  void restoreAfterClose() {
    emit(CustodyInitial());
  }


  // --- Amount dialog (keypad) state ---

  /// Call when opening the amount dialog. Resets amount text.
  void startAmountEditing() {
    emit(CustodyAmountEditing(''));
  }

  /// Appends a digit or decimal to the amount text.
  void appendAmountKey(String key) {
    final current =
        state is CustodyAmountEditing
            ? (state as CustodyAmountEditing).amountText
            : '';
    emit(CustodyAmountEditing(current + key));
  }

  /// Removes the last character from the amount text.
  void deleteAmountLast() {
    final current =
        state is CustodyAmountEditing
            ? (state as CustodyAmountEditing).amountText
            : '';
    if (current.isEmpty) return;
    emit(CustodyAmountEditing(current.substring(0, current.length - 1)));
  }

  /// Returns the parsed amount, or null if empty/invalid.
  double? getAmountValue() {
    final current =
        state is CustodyAmountEditing
            ? (state as CustodyAmountEditing).amountText
            : '';
    final trimmed = current.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }

  /// Call when the amount dialog is dismissed to leave amount-editing state.
  void restoreAfterAmountDialog() {
    emit(CustodyInitial());
  }
}
