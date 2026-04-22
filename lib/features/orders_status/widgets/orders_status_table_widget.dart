import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/custom_text.dart';
import '../model/order_status_row_model.dart';

class OrdersStatusTableWidget extends StatelessWidget {
  const OrdersStatusTableWidget({
    super.key,
    required this.orders,
    required this.onPrintOrder,
    required this.onOpenOrderInCart,
  });

  final List<OrderStatusRowModel> orders;
  final Future<void> Function(int orderId) onPrintOrder;
  final Future<void> Function(int orderId) onOpenOrderInCart;

  static String _formatCreatedAt(String? value) {
    if (value == null || value.isEmpty) return '-';
    try {
      final dt = DateTime.parse(value);
      final datePart = DateFormat('yyyy-MM-dd').format(dt);
      final timePart = DateFormat('HH:mm:ss').format(dt);
      return '$datePart\n$timePart';
    } catch (_) {
      return value;
    }
  }

  static String _formatMoney(double amount) {
    return amount.toStringAsFixed(2);
  }

  ButtonStyle _actionButtonStyle() {
    return OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      side: const BorderSide(color: AppColors.greyE6E9EA, width: 1.5),
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  ButtonStyle _printButtonStyle() {
    return OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      side: const BorderSide(color: AppColors.deepPrimary, width: 1.5),
      backgroundColor: AppColors.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          'orders_status.no_records'.tr(),
          style: const TextStyle(color: AppColors.greyA4ACAD, fontSize: 16),
        ),
      );
    }

    final printText = 'orders_status.print'.tr();
    final editText = 'actions.edit'.tr();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(AppColors.secondary),
                  columns: [
                    DataColumn(label: Text('table.id'.tr())),
                    DataColumn(label: Text('orders_status.created_at'.tr())),
                    DataColumn(label: Text('orders_status.total'.tr())),
                    DataColumn(label: Text('orders_status.order_type'.tr())),
                    DataColumn(
                      label: Text('orders_status.payment_method'.tr()),
                    ),
                    DataColumn(label: Text('orders_status.table_number'.tr())),
                    DataColumn(label: Text('orders_status.cashier'.tr())),
                    DataColumn(label: Text('orders_status.customer'.tr())),
                    DataColumn(label: Text('orders_status.actions'.tr())),
                  ],
                  rows: [
                    for (final entry in orders.asMap().entries)
                      DataRow(
                        color: WidgetStateProperty.all(
                          entry.key.isEven ? Colors.white : AppColors.fillColor,
                        ),
                        cells: [
                          DataCell(
                            CustomText(
                              needSelectable: true,
                              text: '#${entry.value.id}',
                              style: AppFonts.styleBold16.copyWith(
                                fontFamily: AppFonts.enFamily,
                              ),
                            ),
                          ),
                          DataCell(
                            CustomText(
                              needSelectable: true,
                              text:
                                  '\u200E${_formatCreatedAt(entry.value.createdAt)}',
                              style: AppFonts.styleBold16.copyWith(
                                fontFamily: AppFonts.enFamily,
                              ),
                            ),
                          ),
                          DataCell(
                            CustomText(
                              needSelectable: true,
                              text:
                                  '${_formatMoney(entry.value.total)}\n${'products.currency'.tr()}',
                              style: AppFonts.styleBold16.copyWith(
                                fontFamily: AppFonts.enFamily,
                              ),
                            ),
                          ),
                          DataCell(
                            CustomText(
                              needSelectable: true,
                              text: entry.value.orderTypeName,
                              style: AppFonts.styleBold16.copyWith(
                                fontFamily:
                                    AppFonts.getCurrentFontFamilyBasedOnText(
                                      entry.value.orderTypeName,
                                    ),
                              ),
                            ),
                          ),
                          DataCell(
                            CustomText(
                              needSelectable: true,
                              text: entry.value.paymentMethodName,
                              style: AppFonts.styleBold16.copyWith(
                                fontFamily:
                                    AppFonts.getCurrentFontFamilyBasedOnText(
                                      entry.value.paymentMethodName,
                                    ),
                              ),
                            ),
                          ),
                          DataCell(
                            CustomText(
                              needSelectable: true,
                              text:
                                  (entry.value.tableNumber?.trim().isEmpty ??
                                          true)
                                      ? '-'
                                      : entry.value.tableNumber!,
                              style: AppFonts.styleBold16.copyWith(
                                fontFamily: AppFonts.enFamily,
                              ),
                            ),
                          ),
                          DataCell(
                            CustomText(
                              needSelectable: true,
                              text: entry.value.cashierName,
                              style: AppFonts.styleBold16.copyWith(
                                fontFamily:
                                    AppFonts.getCurrentFontFamilyBasedOnText(
                                      entry.value.cashierName,
                                    ),
                              ),
                            ),
                          ),
                          DataCell(
                            CustomText(
                              needSelectable: true,
                              text: entry.value.customerName,
                              style: AppFonts.styleBold16.copyWith(
                                fontFamily:
                                    AppFonts.getCurrentFontFamilyBasedOnText(
                                      entry.value.customerName,
                                    ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                OutlinedButton(
                                  style: _printButtonStyle(),
                                  onPressed: () async {
                                    await onPrintOrder(entry.value.id);
                                  },
                                  child: Text(
                                    printText,
                                    style: AppFonts.styleMedium14.copyWith(
                                      fontFamily:
                                          AppFonts.getCurrentFontFamilyBasedOnText(
                                            printText,
                                          ),
                                      color: AppColors.deepPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  style: _actionButtonStyle(),
                                  onPressed: () async {
                                    await onOpenOrderInCart(entry.value.id);
                                  },
                                  child: Text(
                                    editText,
                                    style: AppFonts.styleMedium14.copyWith(
                                      fontFamily:
                                          AppFonts.getCurrentFontFamilyBasedOnText(
                                            editText,
                                          ),
                                      color: AppColors.deepPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
