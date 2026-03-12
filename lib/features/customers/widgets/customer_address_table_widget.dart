import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/action_icon_widget.dart';
import '../../../core/widgets/custom_text.dart';
import '../cubit/customer_search_cubit.dart';
import '../model/customer_address_row.dart';

class CustomerAddressTableWidget extends StatelessWidget {
  const CustomerAddressTableWidget({
    super.key,
    required this.rows,
    this.selectedAddressId,
    this.onAddressSelected,
    this.onDeleteCustomer,
  });

  final List<CustomerAddressRow> rows;
  final int? selectedAddressId;
  final void Function(CustomerAddressRow row)? onAddressSelected;
  final void Function(CustomerAddressRow row)? onDeleteCustomer;

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
                DataColumn(label: Text('customers.table.select'.tr())),
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
                      DataCell(
                        Radio<int>(
                          value: rows[i].addressId,
                          groupValue: selectedAddressId,
                          onChanged: onAddressSelected != null
                              ? (_) {
                                  context
                                      .read<CustomerSearchCubit>()
                                      .setSelectedAddress(rows[i].addressId);
                                }
                              : null,
                          activeColor: AppColors.secondary,
                        ),
                      ),
                      DataCell(
                        CustomText(
                          text: _str(rows[i].name),
                          needSelectable: true,
                        ),
                      ),
                      DataCell(
                        CustomText(text: rows[i].phone, needSelectable: true),
                      ),
                      DataCell(
                        CustomText(
                          text: _str(rows[i].zoneName),
                          needSelectable: true,
                        ),
                      ),
                      DataCell(
                        CustomText(
                          text: _str(rows[i].buildingNumber),
                          needSelectable: true,
                        ),
                      ),
                      DataCell(
                        CustomText(
                          text: _str(rows[i].floor),
                          needSelectable: true,
                        ),
                      ),
                      DataCell(
                        CustomText(
                          text: _str(rows[i].apartment),
                          needSelectable: true,
                        ),
                      ),
                      DataCell(
                        onDeleteCustomer != null
                            ? ActionIcon(
                                icon: Icons.delete_outline,
                                tooltip: 'actions.delete'.tr(),
                                onTap: () => onDeleteCustomer!(rows[i]),
                              )
                            : const SizedBox.shrink(),
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
