import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../cart/orders/model/order_model.dart';
import '../../cart/orders/model/order_type_model.dart';
import '../../cart/orders/repos/offline/orders_offline_repos.dart';
import '../../custody/model/custody_model.dart';
import '../../custody/repos/offline/custody_offline_repos.dart';
import '../../general_settings/general_settings_keys.dart';
import '../../general_settings/repos/offline/general_settings_offline_repos.dart';
import '../../price_lists/model/price_list_model.dart';
import '../../price_lists/repos/offline/price_lists_offline_repos.dart';
import '../../../core/services/windows_thermal_printer_service.dart';
import '../model/custody_review_report_model.dart';

part 'shift_details_state.dart';

class ShiftDetailsCubit extends Cubit<ShiftDetailsState> {
  ShiftDetailsCubit(
    this.ordersRepo,
    this.priceListsOfflineRepository,
    this.custodyRepo,
    this.generalSettingsRepo,
  ) : _thermalPrinterService = WindowsThermalPrinterService(),
      super(ShiftDetailsInitial());

  ShiftDetailsCubit.withPrinter(
    this.ordersRepo,
    this.priceListsOfflineRepository,
    this.custodyRepo,
    this.generalSettingsRepo,
    this._thermalPrinterService,
  ) : super(ShiftDetailsInitial());

  final OrdersOfflineRepository ordersRepo;
  final PriceListsOfflineRepository priceListsOfflineRepository;
  final CustodyOfflineRepository custodyRepo;
  final GeneralSettingsOfflineRepository generalSettingsRepo;
  final WindowsThermalPrinterService _thermalPrinterService;

  CustodyReviewReportModel? _currentReport;
  String _currentReceiptPreview = '';

  Future<void> loadReport({required int custodyId}) async {
    emit(ShiftDetailsLoading());

    final custodyResult = await custodyRepo.getById(custodyId);
    final custody = custodyResult.fold((_) => null, (value) => value);
    if (custody == null) {
      emit(ShiftDetailsError(message: 'Shift custody not found'));
      return;
    }

    final orderTypesResult = await ordersRepo.getOrderTypes();
    final orderTypes = orderTypesResult.fold<List<OrderTypeModel>>(
      (_) => const [],
      (types) => types,
    );

    final priceListsResult = await priceListsOfflineRepository.getAll();
    final priceLists = priceListsResult.fold<List<PriceListModel>>(
      (_) => const [],
      (list) => list,
    );

    final ordersResult = await ordersRepo.getOrdersByCustodyId(custodyId);
    ordersResult.fold(
      (failure) => emit(
        ShiftDetailsError(
          message: failure.failureMessage ?? 'Error loading orders',
        ),
      ),
      (orders) {
        final report = _buildReport(
          custody: custody,
          orders: orders,
          orderTypes: orderTypes,
          priceLists: priceLists,
        );
        final receiptPreview = _buildReceiptText(report);
        _currentReport = report;
        _currentReceiptPreview = receiptPreview;
        emit(
          ShiftDetailsLoaded(report: report, receiptPreview: receiptPreview),
        );
      },
    );
  }

  Future<bool> printCustodyReviewReceipt() async {
    final report = _currentReport;
    if (report == null || _currentReceiptPreview.trim().isEmpty) {
      return false;
    }

    emit(
      ShiftDetailsPrinting(
        report: report,
        receiptPreview: _currentReceiptPreview,
      ),
    );
    final printerName = await _resolvePrinterName();
    if (printerName == null) {
      emit(
        ShiftDetailsLoaded(
          report: report,
          receiptPreview: _currentReceiptPreview,
        ),
      );
      return false;
    }

    final printOk = await _thermalPrinterService.printText(
      printerName: printerName,
      text: _currentReceiptPreview,
      copies: 1,
      fontSize: 11,
      paperWidthMm: 80,
      rightToLeft: true,
    );

    emit(
      ShiftDetailsLoaded(
        report: report,
        receiptPreview: _currentReceiptPreview,
      ),
    );
    return printOk;
  }

  CustodyReviewReportModel _buildReport({
    required CustodyModel custody,
    required List<OrderModel> orders,
    required List<OrderTypeModel> orderTypes,
    required List<PriceListModel> priceLists,
  }) {
    final orderTypeNameById = <int, String>{
      for (final type in orderTypes) type.id: type.name,
    };
    final priceListById = <int, PriceListModel>{
      for (final list in priceLists)
        if (list.id != null) list.id!: list,
    };

    final dailyCountsByDate = <DateTime, _DailyOrderMutable>{};
    final financeByCurrency = <String, _CurrencyFinanceMutable>{};

    for (final order in orders) {
      final day = _extractOrderDay(order.createdAt);
      if (day != null) {
        final daySummary = dailyCountsByDate.putIfAbsent(
          day,
          () => _DailyOrderMutable(),
        );
        daySummary.totalOrdersCount += 1;
        final orderTypeName = _resolveOrderTypeName(
          order.orderType,
          orderTypeNameById,
        );
        daySummary.ordersCountByType[orderTypeName] =
            (daySummary.ordersCountByType[orderTypeName] ?? 0) + 1;
      }

      final priceList = priceListById[order.selectedPriceListId];
      final currencyName = _resolveCurrencyName(priceList);
      final currencySummary = financeByCurrency.putIfAbsent(
        currencyName,
        () => _CurrencyFinanceMutable(),
      );
      final orderTypeName = _resolveOrderTypeName(
        order.orderType,
        orderTypeNameById,
      );
      currencySummary.totalsByOrderType[orderTypeName] =
          (currencySummary.totalsByOrderType[orderTypeName] ?? 0) + order.total;
      currencySummary.currencyTotal += order.total;
    }

    final dailyOrderCounts =
        dailyCountsByDate.entries.map((entry) {
            return DailyOrderCountModel(
              dayDate: entry.key,
              totalOrdersCount: entry.value.totalOrdersCount,
              ordersCountByType: Map<String, int>.from(
                entry.value.ordersCountByType,
              ),
            );
          }).toList()
          ..sort((a, b) => a.dayDate.compareTo(b.dayDate));

    final financeSummaries =
        financeByCurrency.entries.map((entry) {
            return CurrencyFinanceSummaryModel(
              currencyName: entry.key,
              totalsByOrderType: Map<String, double>.from(
                entry.value.totalsByOrderType,
              ),
              currencyTotal: entry.value.currencyTotal,
            );
          }).toList()
          ..sort((a, b) => a.currencyName.compareTo(b.currencyName));

    final grandTotalByCurrency = <String, double>{
      for (final item in financeSummaries)
        item.currencyName: item.currencyTotal,
    };

    return CustodyReviewReportModel(
      custodyId: custody.id ?? 0,
      shiftStartedAt: _safeDateTime(
        custody.shiftStartedAt ?? custody.createdAt,
      ),
      shiftEndedAt: _safeDateTime(custody.shiftEndedAt),
      cashOnHandAtShiftStart: custody.totalWhenCreate,
      cashOnHandAtShiftEnd:
          custody.isClosed && custody.totalWhenClose != null
              ? custody.totalWhenClose
              : null,
      dailyOrderCounts: dailyOrderCounts,
      financeByCurrency: financeSummaries,
      grandTotalByCurrency: grandTotalByCurrency,
      overallOrdersCount: orders.length,
    );
  }

  String _buildReceiptText(CustodyReviewReportModel report) {
    final buffer = StringBuffer();
    final dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
    final dateOnlyFormat = DateFormat('dd/MM/yyyy');
    buffer.writeln('==============================');
    buffer.writeln('مراجعة العهدة');
    buffer.writeln('==============================');
    buffer.writeln('رقم العهدة: #${report.custodyId}');
    buffer.writeln(
      'بداية الوردية: ${report.shiftStartedAt == null ? '—' : dateTimeFormat.format(report.shiftStartedAt!)}',
    );
    buffer.writeln(
      'نهاية الوردية: ${report.shiftEndedAt == null ? '—' : dateTimeFormat.format(report.shiftEndedAt!)}',
    );
    buffer.writeln(
      'النقدية عند بداية الوردية: ${report.cashOnHandAtShiftStart.toStringAsFixed(2)}',
    );
    buffer.writeln(
      report.cashOnHandAtShiftEnd == null
          ? 'النقدية عند نهاية الوردية: — (العهدة مفتوحة)'
          : 'النقدية عند نهاية الوردية: ${report.cashOnHandAtShiftEnd!.toStringAsFixed(2)}',
    );
    buffer.writeln('عدد الطلبات: ${report.overallOrdersCount}');
    buffer.writeln('==============================');
    buffer.writeln('عدد الطلبات حسب اليوم');
    if (report.dailyOrderCounts.isEmpty) {
      buffer.writeln('لا توجد طلبات في هذه العهدة');
    } else {
      for (final day in report.dailyOrderCounts) {
        buffer.writeln(
          '${dateOnlyFormat.format(day.dayDate)} — الإجمالي: ${day.totalOrdersCount}',
        );
        final typeEntries =
            day.ordersCountByType.entries.toList()
              ..sort((a, b) => a.key.compareTo(b.key));
        for (final typeEntry in typeEntries) {
          buffer.writeln(
            '  ${_orderTypeLabelAr(typeEntry.key)}: ${typeEntry.value}',
          );
        }
      }
    }

    buffer.writeln('==============================');
    buffer.writeln('المالية حسب العملة');
    if (report.financeByCurrency.isEmpty) {
      buffer.writeln('لا توجد بيانات مالية');
    } else {
      for (final currency in report.financeByCurrency) {
        buffer.writeln('العملة: ${currency.currencyName}');
        final totals =
            currency.totalsByOrderType.entries.toList()
              ..sort((a, b) => a.key.compareTo(b.key));
        for (final item in totals) {
          buffer.writeln(
            '  ${_orderTypeLabelAr(item.key)}: ${item.value.toStringAsFixed(2)}',
          );
        }
        buffer.writeln(
          '  الإجمالي: ${currency.currencyTotal.toStringAsFixed(2)}',
        );
      }
    }
    buffer.writeln('==============================');
    buffer.writeln('شكراً للمراجعة');
    buffer.writeln('\n\n\n');
    return buffer.toString();
  }

  /// Maps DB order type keys (e.g. hall) to Arabic labels for the receipt.
  String _orderTypeLabelAr(String keyOrName) {
    final n = keyOrName.trim().toLowerCase();
    switch (n) {
      case 'hall':
        return 'صالة';
      case 'takeaway':
        return 'تيك أواي';
      case 'delivery':
        return 'توصيل';
      default:
        return keyOrName;
    }
  }

  Future<String?> _resolvePrinterName() async {
    final settingsResult = await generalSettingsRepo.getAllAsMap();
    return settingsResult.fold((_) => null, (map) {
      final customer =
          (map[GeneralSettingsKeys.customerPrinterName] ?? '').trim();
      if (customer.isNotEmpty) return customer;
      return null;
    });
  }

  DateTime? _extractOrderDay(String? dateValue) {
    final parsed = _safeDateTime(dateValue);
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  DateTime? _safeDateTime(String? dateValue) {
    if (dateValue == null || dateValue.trim().isEmpty) return null;
    return DateTime.tryParse(dateValue);
  }

  String _resolveOrderTypeName(
    int orderTypeId,
    Map<int, String> orderTypeNameById,
  ) {
    final name = orderTypeNameById[orderTypeId];
    if (name == null || name.trim().isEmpty) {
      return 'نوع $orderTypeId';
    }
    return name;
  }

  String _resolveCurrencyName(PriceListModel? priceList) {
    final currencyName = priceList?.currencyName?.trim();
    if (currencyName != null && currencyName.isNotEmpty) {
      return currencyName;
    }
    final fallback = priceList?.name?.trim();
    if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }
    return 'عملة غير معروفة';
  }
}

class _DailyOrderMutable {
  int totalOrdersCount = 0;
  final Map<String, int> ordersCountByType = {};
}

class _CurrencyFinanceMutable {
  final Map<String, double> totalsByOrderType = {};
  double currencyTotal = 0;
}
