import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_dropdown.dart';
import '../../../price_lists/model/price_list_model.dart';
import '../../cubit/create_order_cubit.dart';

/// Price list dropdown driven by [CreateOrderCubit]. All logic lives in cubit.
class PriceListDropdown extends StatelessWidget {
  const PriceListDropdown({super.key, required this.cubit});

  final CreateOrderCubit cubit;

  @override
  Widget build(BuildContext context) {
    return CustomDropDown<PriceListModel>(
      items: cubit.validPriceLists,
      value: cubit.selectedPriceList,
      label: 'create_order.select_price_plan'.tr(),
      hideWhenEmpty: false,
      emptyMessage: 'create_order.no_price_lists'.tr(),
      itemLabelBuilder: cubit.priceListLabel,
      onChanged: (PriceListModel? pl) => cubit.setSelectedPriceListId(pl?.id),
    );
  }
}
