import '../../create_order/model/create_order_line_model.dart';
import '../../customers/model/customer_address_row.dart';
import '../../../core/services/windows_thermal_printer_service.dart';

class OrderReceiptService {
  OrderReceiptService(this._printerService);

  final WindowsThermalPrinterService _printerService;

  String buildCustomerArabicReceipt({
    required int orderId,
    required String createdAt,
    required String branchName,
    required String orderTypeNameAr,
    required List<CreateOrderLineModel> items,
    required double subtotal,
    required double discount,
    required double taxPercentage,
    required CustomerAddressRow? customer,
    String? tableNumber,
    String? waiterName,
    String? restaurantName,
    String? footerSlogan,
  }) {
    final taxableAmount = (subtotal - discount).clamp(0.0, double.infinity);
    final taxAmount = taxableAmount * (taxPercentage / 100);
    final totalAfterTax = taxableAmount + taxAmount;

    final b = StringBuffer();
    _appendWrapped(
      b,
      (restaurantName == null || restaurantName.trim().isEmpty)
          ? 'مطعم إياتك'
          : restaurantName.trim(),
    );
    b.writeln('------------------------------');
    b.writeln('كود الطلب: #$orderId');
    b.writeln('التاريخ: ${_formatCreatedAt(createdAt)}');
    b.writeln('الفرع: $branchName');
    b.writeln('نوع الطلب: $orderTypeNameAr');
    if ((tableNumber ?? '').trim().isNotEmpty) {
      b.writeln('الطاولة: ${tableNumber!.trim()}');
    }
    if ((waiterName ?? '').trim().isNotEmpty) {
      _appendWrapped(b, 'الويتر: ${waiterName!.trim()}');
    }
    if (customer != null) {
      b.writeln('------------------------------');
      _appendWrapped(b, 'العميل: ${customer.name ?? '-'}');
      _appendWrapped(b, 'الهاتف: ${customer.phone}');
      if ((customer.secondPhone ?? '').trim().isNotEmpty) {
        _appendWrapped(b, 'هاتف إضافي: ${customer.secondPhone}');
      }
      _appendWrapped(b, 'المنطقة: ${customer.zoneName}');
      _appendWrapped(b, 'المبنى: ${customer.buildingNumber ?? '-'}');
      _appendWrapped(b, 'الدور: ${customer.floor ?? '-'}');
      _appendWrapped(b, 'الشقة: ${customer.apartment ?? '-'}');
    }
    b.writeln('==============================');
    _appendCustomerItemsTable(b, items);
    b.writeln('الإجمالي الفرعي: ${subtotal.toStringAsFixed(2)}');
    if (discount > 0) {
      b.writeln('الخصم: -${discount.toStringAsFixed(2)}');
    }
    b.writeln(
      'الضريبة (${taxPercentage.toStringAsFixed(2)}%): ${taxAmount.toStringAsFixed(2)}',
    );
    b.writeln('الإجمالي بعد الضريبة: ${totalAfterTax.toStringAsFixed(2)}');
    b.writeln('==============================');
    _appendWrapped(
      b,
      (footerSlogan == null || footerSlogan.trim().isEmpty)
          ? 'شكرا لزيارتكم'
          : footerSlogan.trim(),
    );
    b.writeln('\n\n\n');
    return b.toString();
  }

  String buildKitchenArabicReceipt({
    required int orderId,
    required String createdAt,
    required String orderTypeNameAr,
    required List<CreateOrderLineModel> items,
    String? tableNumber,
    String? waiterName,
  }) {
    final b = StringBuffer();
    b.writeln('طلب المطبخ');
    b.writeln('------------------------------');
    b.writeln('كود الطلب: #$orderId');
    b.writeln('التاريخ: ${_formatCreatedAt(createdAt)}');
    b.writeln('نوع الطلب: $orderTypeNameAr');
    if ((tableNumber ?? '').trim().isNotEmpty) {
      b.writeln('الطاولة: ${tableNumber!.trim()}');
    }
    if ((waiterName ?? '').trim().isNotEmpty) {
      _appendWrapped(b, 'الويتر: ${waiterName!.trim()}');
    }
    b.writeln('==============================');
    _appendItemsDetails(b, items);
    b.writeln('==============================');
    b.writeln('\n\n\n');
    return b.toString();
  }

  String _formatCreatedAt(String createdAt) {
    final parsed = DateTime.tryParse(createdAt);
    if (parsed == null) return createdAt;
    final local = parsed.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final minute = local.minute.toString().padLeft(2, '0');
    final hour24 = local.hour;
    final isPm = hour24 >= 12;
    final hour12Raw = hour24 % 12;
    final hour12 = (hour12Raw == 0 ? 12 : hour12Raw).toString().padLeft(2, '0');
    final amPm = isPm ? 'م' : 'ص';
    return '$day/$month/$year $hour12:$minute $amPm';
  }

  void _appendItemsDetails(StringBuffer b, List<CreateOrderLineModel> items) {
    for (final line in items) {
      final unit = line.variantUnitPrice ?? 0;
      _appendWrapped(b, line.productName ?? '-');
      if ((line.variantLabel ?? '').trim().isNotEmpty) {
        _appendWrapped(b, 'التشكيلة: ${line.variantLabel}');
      }
      if (line.selectedOptions.isNotEmpty) {
        for (final option in line.selectedOptions) {
          _appendWrapped(b, ' - ${option.variableName}: ${option.valueLabel}');
        }
      }
      if (line.selectedAddons.isNotEmpty) {
        _appendWrapped(b, 'الإضافات:');
        for (final addon in line.selectedAddons) {
          _appendWrapped(
            b,
            ' + ${addon.name} x${addon.quantity} = ${addon.total.toStringAsFixed(2)}',
          );
        }
      }
      if (line.notes.trim().isNotEmpty) {
        _appendWrapped(b, 'ملاحظات: ${line.notes}');
      }
      _appendWrapped(
        b,
        'الكمية: ${line.quantity} | السعر: ${unit.toStringAsFixed(2)} | الإجمالي: ${line.lineTotal.toStringAsFixed(2)}',
      );
      b.writeln('------------------------------');
    }
  }

  void _appendCustomerItemsTable(
    StringBuffer b,
    List<CreateOrderLineModel> items,
  ) {
    b.writeln('الصنف        | ك | السعر | الإجمالي');
    b.writeln('------------------------------');
    for (final line in items) {
      final itemName = _truncateText((line.productName ?? '-').trim(), 12);
      final qty = line.quantity.toString();
      final unit = (line.variantUnitPrice ?? 0).toStringAsFixed(2);
      final total = line.lineTotal.toStringAsFixed(2);
      b.writeln(
        '${itemName.padRight(12)}|${qty.padLeft(2)}|${unit.padLeft(7)}|${total.padLeft(8)}',
      );

      if ((line.variantLabel ?? '').trim().isNotEmpty) {
        _appendWrapped(b, 'التشكيلة: ${line.variantLabel}');
      }
      if (line.selectedOptions.isNotEmpty) {
        for (final option in line.selectedOptions) {
          _appendWrapped(b, ' - ${option.variableName}: ${option.valueLabel}');
        }
      }
      if (line.selectedAddons.isNotEmpty) {
        _appendWrapped(b, 'الإضافات:');
        for (final addon in line.selectedAddons) {
          _appendWrapped(
            b,
            ' + ${addon.name} x${addon.quantity} = ${addon.total.toStringAsFixed(2)}',
          );
        }
      }
      if (line.notes.trim().isNotEmpty) {
        _appendWrapped(b, 'ملاحظات: ${line.notes}');
      }
      b.writeln('------------------------------');
    }
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    if (maxLength <= 1) return text.substring(0, maxLength);
    return '${text.substring(0, maxLength - 1)}…';
  }

  void _appendWrapped(StringBuffer b, String value, {int width = 30}) {
    final clean = value.trim();
    if (clean.isEmpty) {
      b.writeln();
      return;
    }
    if (clean.length <= width) {
      b.writeln(clean);
      return;
    }
    var start = 0;
    while (start < clean.length) {
      final end = (start + width > clean.length) ? clean.length : start + width;
      b.writeln(clean.substring(start, end));
      start = end;
    }
  }

  Future<bool> printReceipt({
    required String printerName,
    required String receiptText,
    required int copies,
    double fontSize = 12,
    int paperWidthMm = 80,
    bool rightToLeft = true,
    String? headerImagePath,
    String? footerImagePath,
    int headerImageMaxHeightPx = 160,
    int footerImageMaxHeightPx = 120,
  }) {
    return _printerService.printText(
      printerName: printerName,
      text: receiptText,
      copies: copies,
      fontSize: fontSize,
      paperWidthMm: paperWidthMm,
      rightToLeft: rightToLeft,
      headerImagePath: headerImagePath,
      footerImagePath: footerImagePath,
      headerImageMaxHeightPx: headerImageMaxHeightPx,
      footerImageMaxHeightPx: footerImageMaxHeightPx,
    );
  }
}
