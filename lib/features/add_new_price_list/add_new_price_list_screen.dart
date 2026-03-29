import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../../services_locator/service_locator.dart';
import '../price_lists/model/price_list_model.dart';
import 'cubit/add_new_price_list_cubit.dart';
import 'widgets/add_new_price_list_form_widget.dart';

class AddNewPriceListScreen extends StatelessWidget {
  const AddNewPriceListScreen({super.key, this.priceList});
  final PriceListModel? priceList;

  @override
  Widget build(BuildContext context) {
    return CustomPadding(
      child: BlocProvider<AddNewPriceListCubit>(
        create: (context) {
          final cubit = getIt<AddNewPriceListCubit>()
            ..setPriceList(priceList)
            ..loadCurrencies();
          return cubit;
        },
        child: BlocConsumer<AddNewPriceListCubit, AddNewPriceListState>(
          listener: (context, state) {
            if (state is AddNewPriceListSaved) {
              final messenger = ScaffoldMessenger.of(context);
              context.pop<bool>(true);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    priceList != null
                        ? 'add_price_list_form.update_success'.tr()
                        : 'add_price_list_form.success'.tr(),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is AddNewPriceListLoadingCurrencies) {
              return const CustomLoading();
            }
            if (state is AddNewPriceListError) {
              return CustomFailedWidget(message: state.message);
            }
            if (state is AddNewPriceListLoading) {
              return const CustomLoading();
            }
            return const AddNewPriceListFormWidget();
          },
        ),
      ),
    );
  }
}
