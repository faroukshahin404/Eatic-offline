import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../../services_locator/service_locator.dart';
import '../restaurant_tables/model/restaurant_table_model.dart';
import 'cubit/add_new_restaurant_table_cubit.dart';
import 'widgets/add_new_restaurant_table_form_widget.dart';

class AddNewRestaurantTableScreen extends StatelessWidget {
  const AddNewRestaurantTableScreen({super.key, this.restaurantTable});
  final RestaurantTableModel? restaurantTable;

  @override
  Widget build(BuildContext context) {
    return CustomPadding(
      child: BlocProvider<AddNewRestaurantTableCubit>(
        create: (context) {
          final cubit = getIt<AddNewRestaurantTableCubit>();
          cubit.setRestaurantTable(restaurantTable);
          cubit.loadBranches();
          return cubit;
        },
        child:
            BlocConsumer<
              AddNewRestaurantTableCubit,
              AddNewRestaurantTableState
            >(
              listener: (context, state) {
                if (state is AddNewRestaurantTableSaved) {
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.of(context).pop<bool>(true);
                  final message = state.isUpdate
                      ? 'add_restaurant_table_form.update_success'.tr()
                      : 'add_restaurant_table_form.success'.tr();
                  messenger.showSnackBar(SnackBar(content: Text(message)));
                }
              },
              builder: (context, state) {
                if (state is AddNewRestaurantTableError) {
                  return CustomFailedWidget(
                    message: state.message,
                    onRetry: () => context
                        .read<AddNewRestaurantTableCubit>()
                        .loadBranches(),
                  );
                }
                if (state is AddNewRestaurantTableSaving) {
                  return const CustomLoading();
                }
                return const AddNewRestaurantTableFormWidget();
              },
            ),
      ),
    );
  }
}
