import 'package:flutter_bloc/flutter_bloc.dart';

import '../../custody/model/custody_model.dart';
import '../../custody/repos/offline/custody_offline_repos.dart';
import 'shifts_state.dart';

class ShiftsCubit extends Cubit<ShiftsState> {
  ShiftsCubit(this._custodyRepo) : super(ShiftsInitial());

  final CustodyOfflineRepository _custodyRepo;

  // ── Filter state managed by the cubit ──────────────────────────────────
  DateTime? _from;
  DateTime? _to;

  DateTime? get from => _from;
  DateTime? get to => _to;

  // ── Public actions ─────────────────────────────────────────────────────

  Future<void> loadAllShifts() async {
    emit(ShiftsLoading());
    final result = await _custodyRepo.getAllCustodies();
    result.fold(
      (f) => emit(ShiftsError(f.failureMessage ?? 'Failed to load shifts')),
      (custodies) => emit(ShiftsLoaded(custodies: custodies)),
    );
  }

  void updateFromDate(DateTime? date) {
    _from = date;
    if (_to != null && _from != null && _to!.isBefore(_from!)) {
      _to = _from;
    }
  }

  void updateToDate(DateTime? date) {
    _to = date;
    if (_from != null && _to != null && _from!.isAfter(_to!)) {
      _from = _to;
    }
  }

  Future<void> search({String? cashierName}) async {
    emit(ShiftsLoading());

    final result = await _custodyRepo.getAllCustodies();
    result.fold(
      (f) => emit(ShiftsError(f.failureMessage ?? 'Failed to load shifts')),
      (custodies) {
        final filtered = _applyFilters(
          custodies,
          cashierName: cashierName?.trim(),
          from: _from,
          to: _to,
        );
        emit(ShiftsLoaded(custodies: filtered, from: _from, to: _to));
      },
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────

  List<CustodyModel> _applyFilters(
    List<CustodyModel> custodies, {
    String? cashierName,
    DateTime? from,
    DateTime? to,
  }) {
    return custodies.where((c) {
      if (cashierName != null && cashierName.isNotEmpty) {
        final name = (c.userModel?.name ?? '').toLowerCase();
        if (!name.contains(cashierName.toLowerCase())) return false;
      }

      if (c.shiftStartedAt != null || c.createdAt != null) {
        try {
          final shiftStartedAt = c.shiftStartedAt ?? c.createdAt;
          if (shiftStartedAt == null) return true;
          final date = DateTime.parse(shiftStartedAt);
          if (from != null) {
            final startOfDay = DateTime(from.year, from.month, from.day);
            if (date.isBefore(startOfDay)) return false;
          }
          if (to != null) {
            final endOfDay = DateTime(
              to.year,
              to.month,
              to.day,
              23,
              59,
              59,
              999,
            );
            if (date.isAfter(endOfDay)) return false;
          }
        } catch (_) {}
      }

      return true;
    }).toList();
  }
}
