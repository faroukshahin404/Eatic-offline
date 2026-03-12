import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/custom_button_widget.dart';
import '../../../routes/app_paths.dart';
import '../cubit/customer_search_cubit.dart';
import '../model/customer_address_row.dart';
import 'customer_address_table_widget.dart';

class CustomerSearchLoadedContent extends StatelessWidget {
  const CustomerSearchLoadedContent({
    super.key,
    required this.cubit,
  });

  final CustomerSearchCubit cubit;

  static Future<void> _confirmDeleteCustomer(
    BuildContext context,
    CustomerAddressRow row,
    CustomerSearchCubit cubit,
  ) async {
    final name = (row.name?.trim().isEmpty ?? true)
        ? row.phone
        : (row.name ?? row.phone);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('actions.delete'.tr()),
        content:
            Text('customers.delete_confirm'.tr(namedArgs: {'name': name})),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('create_order.no'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('create_order.yes'.tr()),
          ),
        ],
      ),
    );
    if (context.mounted && confirmed == true) {
      await cubit.deleteCustomer(row.customerId);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('customers.deleted'.tr())));
      }
    }
  }

  Future<void> _onAddAddressPressed(BuildContext context) async {
    final row = cubit.rowForNewAddress;
    if (row == null) return;
    final result = await context.push<bool>(
      AppPaths.addCustomer,
      extra: row.customerId,
    );
    if (context.mounted && result == true) {
      context.read<CustomerSearchCubit>().search();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomerAddressTableWidget(
            rows: cubit.rows,
            selectedAddressId: cubit.selectedAddressId,
            onAddressSelected: (r) => cubit.setSelectedAddress(r.addressId),
            onDeleteCustomer: (row) =>
                _confirmDeleteCustomer(context, row, cubit),
          ),
          if (cubit.rowForNewAddress != null)
            CustomButtonWidget(
              text: 'customers.add_address'.tr(),
              onPressed: () => _onAddAddressPressed(context),
            ),
        ],
      ),
    );
  }
}
