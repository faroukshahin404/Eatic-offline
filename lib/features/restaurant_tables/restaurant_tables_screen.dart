import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/platform_bottom_sheet.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_button_widget.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../add_new_restaurant_table/add_new_restaurant_table_screen.dart';
import 'cubit/restaurant_tables_cubit.dart';
import 'model/restaurant_table_model.dart';
import 'widgets/list_of_restaurant_tables_widget.dart';

class RestaurantTablesScreen extends StatelessWidget {
  const RestaurantTablesScreen({super.key});

  static Future<void> restaurantTableDetails(
    BuildContext context, {
    RestaurantTableModel? restaurantTable,
  }) async {
    final result = await PlatformSheet.show(
      context: context,
      isScrollControlled: false,
      child: AddNewRestaurantTableScreen(restaurantTable: restaurantTable),
    );
    if (result == true) {
      if (!(context.mounted)) return;
      context.read<RestaurantTablesCubit>().getAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'restaurant_tables'),
      body: CustomPadding(
        child: BlocBuilder<RestaurantTablesCubit, RestaurantTablesState>(
          builder: (context, state) {
            if (state is RestaurantTablesLoading) {
              return const CustomLoading();
            }
            if (state is RestaurantTablesError ||
                state is RestaurantTablesDeleteError) {
              final message = state is RestaurantTablesError
                  ? state.message
                  : (state as RestaurantTablesDeleteError).message;
              return CustomFailedWidget(
                message: message,
                onRetry: () =>
                    context.read<RestaurantTablesCubit>().getAll(),
              );
            }
            final restaurantTables =
                context.read<RestaurantTablesCubit>().restaurantTables;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                CustomButtonWidget(
                  text: 'add_restaurant_table',
                  onPressed: () async {
                    restaurantTableDetails(context);
                  },
                ),
                Expanded(
                  child: ListOfRestaurantTablesWidget(
                    restaurantTables: restaurantTables,
                    onEdit: (item) => restaurantTableDetails(context,
                        restaurantTable: item),
                    onDelete: (item) {
                      context
                          .read<RestaurantTablesCubit>()
                          .deleteById(item.id!);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
