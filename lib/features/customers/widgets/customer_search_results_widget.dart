import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_button_widget.dart';
import '../../../core/widgets/custom_failed_widget.dart';
import '../../../core/widgets/custom_loading.dart';
import '../../../routes/app_paths.dart';
import '../../_main/cubit/main_cubit.dart';
import '../cubit/customer_search_cubit.dart';
import '../model/customer_address_row.dart';
import 'customer_address_table_widget.dart';

class CustomerSearchResultsWidget extends StatelessWidget {
  const CustomerSearchResultsWidget({super.key});

  static Future<void> _confirmDeleteCustomer(
    BuildContext context,
    CustomerAddressRow row,
    CustomerSearchCubit cubit,
  ) async {
    final name = (row.name?.trim().isEmpty ?? true) ? row.phone : (row.name ?? row.phone);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('actions.delete'.tr()),
        content: Text(
          'customers.delete_confirm'.tr(namedArgs: {'name': name}),
        ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('customers.deleted'.tr())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerSearchCubit, CustomerSearchState>(
      builder: (context, state) {
        if (state is CustomerSearchLoading) {
          return const CustomLoading();
        }
        if (state is CustomerSearchError) {
          return CustomFailedWidget(
            message: state.message,
            onRetry: () => context.read<CustomerSearchCubit>().runSearch(),
          );
        }
        if (state is CustomerSearchLoaded) {
          final cubit = context.read<CustomerSearchCubit>();
          return Column(
            children: [
              Expanded(
                child: CustomerAddressTableWidget(
                  rows: cubit.rows,
                  selectedAddressId: cubit.selectedAddressId,
                  onAddressSelected: (r) =>
                      cubit.setSelectedAddress(r.addressId),
                  onDeleteCustomer: (row) => _confirmDeleteCustomer(
                    context,
                    row,
                    cubit,
                  ),
                ),
              ),
              if (cubit.rowForNewAddress != null) ...[
                CustomButtonWidget(
                  text: 'customers.add_address'.tr(),
                  onPressed: () {
                    final customerId = cubit.rowForNewAddress!.customerId;
                    context.read<MainCubit>().setCurrentScreen(
                      screen: AppPaths.addCustomer,
                      data: customerId,
                    );
                  },
                ),
              ],
            ],
          );
        }
        return Center(
          child: Text(
            'customers.no_results'.tr(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }
}
