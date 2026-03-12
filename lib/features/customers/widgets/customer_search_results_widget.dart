import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_button_widget.dart';
import '../../../core/widgets/custom_failed_widget.dart';
import '../../../core/widgets/custom_loading.dart';
import '../../../routes/app_paths.dart';
import '../../_main/cubit/main_cubit.dart';
import '../../cart/cubit/cart_cubit.dart';
import '../cubit/customer_search_cubit.dart';
import 'customer_search_loaded_content.dart';

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
          final cubit = context.read<CustomerSearchCubit>();
          return Column(
            children: [
              Expanded(child: CustomerSearchLoadedContent(cubit: cubit)),
              CustomButtonWidget(
                text: 'customers.select_customer'.tr(),
                onPressed: () {
                  final row = cubit.rowForNewAddress;
                  if (row != null) {
                    context.read<CartCubit>().setSelectedCustomer(row);
                    context.read<MainCubit>().setCurrentScreen();
                  }
                },
              ),
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
