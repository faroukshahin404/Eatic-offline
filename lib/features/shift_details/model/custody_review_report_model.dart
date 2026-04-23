class CustodyReviewReportModel {
  const CustodyReviewReportModel({
    required this.custodyId,
    required this.shiftStartedAt,
    required this.shiftEndedAt,
    required this.cashOnHandAtShiftStart,
    required this.cashOnHandAtShiftEnd,
    required this.dailyOrderCounts,
    required this.financeByCurrency,
    required this.grandTotalByCurrency,
    required this.overallOrdersCount,
  });

  final int custodyId;
  final DateTime? shiftStartedAt;
  final DateTime? shiftEndedAt;

  /// Typed cash amount when opening custody (shift start).
  final double cashOnHandAtShiftStart;

  /// Typed cash amount when closing custody (shift end); null if still open.
  final double? cashOnHandAtShiftEnd;
  final List<DailyOrderCountModel> dailyOrderCounts;
  final List<CurrencyFinanceSummaryModel> financeByCurrency;
  final Map<String, double> grandTotalByCurrency;
  final int overallOrdersCount;
}

class DailyOrderCountModel {
  const DailyOrderCountModel({
    required this.dayDate,
    required this.totalOrdersCount,
    required this.ordersCountByType,
  });

  final DateTime dayDate;
  final int totalOrdersCount;
  final Map<String, int> ordersCountByType;
}

class CurrencyFinanceSummaryModel {
  const CurrencyFinanceSummaryModel({
    required this.currencyName,
    required this.totalsByOrderType,
    required this.currencyTotal,
  });

  final String currencyName;
  final Map<String, double> totalsByOrderType;
  final double currencyTotal;
}
