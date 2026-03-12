import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text.dart';
import '../model/customer_address_row.dart';

class CustomerAddressTableWidget extends StatelessWidget {
  const CustomerAddressTableWidget({
    super.key,
    required this.rows,
  });

  final List<CustomerAddressRow> rows;

  static String _str(String? v) => v?.trim().isEmpty ?? true ? '-' : v!;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Center(
        child: Text(
          'customers.no_results'.tr(),
          style: TextStyle(color: AppColors.greyA4ACAD, fontSize: 16),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.secondary),
              columns: [
                DataColumn(label: Text('customers.table.name'.tr())),
                DataColumn(label: Text('customers.table.phone'.tr())),
                DataColumn(label: Text('customers.table.zone'.tr())),
                DataColumn(label: Text('customers.table.building'.tr())),
                DataColumn(label: Text('customers.table.floor'.tr())),
                DataColumn(label: Text('customers.table.apartment'.tr())),
                DataColumn(label: Text('table.actions'.tr())),
              ],
              rows: [
                for (var i = 0; i < rows.length; i++)
                  DataRow(
                    color: WidgetStateProperty.all(
                      i.isEven ? Colors.white : AppColors.fillColor,
                    ),
                    cells: [
                      DataCell(CustomText(text: _str(rows[i].name), needSelectable: true)),
                      DataCell(CustomText(text: rows[i].phone, needSelectable: true)),
                      DataCell(CustomText(text: _str(rows[i].zoneName), needSelectable: true)),
                      DataCell(CustomText(text: _str(rows[i].buildingNumber), needSelectable: true)),
                      DataCell(CustomText(text: _str(rows[i].floor), needSelectable: true)),
                      DataCell(CustomText(text: _str(rows[i].apartment), needSelectable: true)),
                      DataCell(
                        Icon(
                          rows[i].isDefault ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: rows[i].isDefault ? Colors.green : null,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
