import 'package:flutter_bloc/flutter_bloc.dart';

import '../../custody/model/custody_model.dart';
import '../../custody/repos/offline/custody_offline_repos.dart';
import 'shifts_state.dart';

class ShiftsCubit extends Cubit<ShiftsState> {
  ShiftsCubit(this._custodyRepo) : super(ShiftsInitial());

  final CustodyOfflineRepository _custodyRepo;

  Future<void> loadAllShifts() async {
    emit(ShiftsLoading());
    final result = await _custodyRepo.getAllCustodies();
    result.fold(
      (f) => emit(ShiftsError(f.failureMessage ?? 'Failed to load shifts')),
      (custodies) => emit(ShiftsLoaded(custodies)),
    );
  }

  Future<void> search({
    String? cashierName,
    DateTime? from,
    DateTime? to,
  }) async {
    emit(ShiftsLoading());

    final result = await _custodyRepo.getAllCustodies();
    result.fold(
      (f) => emit(ShiftsError(f.failureMessage ?? 'Failed to load shifts')),
      (custodies) {
        final filtered = _applyFilters(
          custodies,
          cashierName: cashierName?.trim(),
          from: from,
          to: to,
        );
        emit(ShiftsLoaded(filtered));
      },
    );
  }

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

      if (c.createdAt != null) {
        try {
          final date = DateTime.parse(c.createdAt!);
          if (from != null) {
            final startOfDay = DateTime(from.year, from.month, from.day);
            if (date.isBefore(startOfDay)) return false;
          }
          if (to != null) {
            final endOfDay =
                DateTime(to.year, to.month, to.day, 23, 59, 59, 999);
            if (date.isAfter(endOfDay)) return false;
          }
        } catch (_) {}
      }

      return true;
    }).toList();
  }
}
