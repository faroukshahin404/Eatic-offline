import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_failed_widget.dart';
import '../../../core/widgets/custom_loading.dart';
import '../cubit/customer_search_cubit.dart';
import 'customer_address_table_widget.dart';

class CustomerSearchResultsWidget extends StatelessWidget {
  const CustomerSearchResultsWidget({super.key});

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
          return CustomerAddressTableWidget(rows: state.rows);
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
