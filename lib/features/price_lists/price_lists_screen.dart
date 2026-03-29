import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/platform_bottom_sheet.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_button_widget.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../add_new_price_list/add_new_price_list_screen.dart';
import 'cubit/price_lists_cubit.dart';
import 'model/price_list_model.dart';
import 'widgets/list_of_price_lists_widget.dart';

class PriceListsScreen extends StatelessWidget {
  const PriceListsScreen({super.key});

  static Future<void> priceListDetails(
    BuildContext context, {
    PriceListModel? priceList,
  }) async {
    final result = await PlatformSheet.show(
      context: context,
      isScrollControlled: false,
      child: AddNewPriceListScreen(priceList: priceList),
    );
    if (result == true) {
      if (!(context.mounted)) return;
      context.read<PriceListsCubit>().getAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'price_lists'),
      body: CustomPadding(
        child: BlocBuilder<PriceListsCubit, PriceListsState>(
          builder: (context, state) {
            if (state is PriceListsLoading) {
              return const CustomLoading();
            }
            if (state is PriceListsError ||
                state is PriceListsDeleteError) {
              final message = state is PriceListsError
                  ? state.message
                  : (state as PriceListsDeleteError).message;
              return CustomFailedWidget(
                message: message,
                onRetry: () => context.read<PriceListsCubit>().getAll(),
              );
            }
            final priceLists =
                context.read<PriceListsCubit>().priceLists;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                CustomButtonWidget(
                  text: 'add_price_list',
                  onPressed: () async {
                    priceListDetails(context);
                  },
                ),
                Expanded(
                  child: ListOfPriceListsWidget(
                    priceLists: priceLists,
                    onEdit: (item) =>
                        priceListDetails(context, priceList: item),
                    onDelete: (item) {
                      context
                          .read<PriceListsCubit>()
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
