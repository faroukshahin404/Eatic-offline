import 'package:Eatic/core/widgets/custom_header_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/custom_button_widget.dart';
import '../../core/widgets/custom_padding.dart';
import '../../routes/app_paths.dart';
import '../_main/cubit/main_cubit.dart';
import 'cubit/customer_search_cubit.dart';
import 'widgets/customer_search_bar_widget.dart';
import 'widgets/customer_search_results_widget.dart';

class CustomerSearchScreen extends StatelessWidget {
  const CustomerSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPadding(
      child: BlocListener<CustomerSearchCubit, CustomerSearchState>(
        listener: (context, state) {
          if (state is CustomerSearchNoResults) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('customers.no_results'.tr())),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomHeaderScreen(title: "customers.title".tr()),
                ),
                CustomButtonWidget(
                  text: "customers.add_customer".tr(),
                  onPressed: () {
                    context.read<MainCubit>().setCurrentScreen(
                      screen: AppPaths.addCustomer,
                    );
                  },
                ),
              ],
            ),
            const CustomerSearchBarWidget(),
            const Expanded(child: CustomerSearchResultsWidget()),
          ],
        ),
      ),
    );
  }
}
