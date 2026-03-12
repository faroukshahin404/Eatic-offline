import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/widgets/custom_grid_view.dart';
import '../../cubit/create_order_cubit.dart';
import '../../model/create_order_variant_model.dart';
import 'create_order_variant_card.dart';

/// Legacy grid layout when variable groups are empty (fallback).
class VariantsGridLayout extends StatelessWidget {
  const VariantsGridLayout({super.key, required this.cubit});

  final CreateOrderCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'create_order.variants_count'.tr(),
            style: AppFonts.styleBold16.copyWith(
              color: AppColors.oppositeColor,
            ),
          ),
        ),
        CustomGridView<CreateOrderVariantModel>(
          items: cubit.variants,
          scrollable: false,
          selectedItem: cubit.selectedVariant,
          onSelectionChanged: (v) => cubit.setSelectedVariant(v),
          itemEquals: (a, b) => a.id == b.id,
          itemBuilder: (context, v) {
            if (v.isActive == true) {
              final index = cubit.variants.indexOf(v);
              final name = v.variableLabels.isEmpty
                  ? 'create_order.variant_n'.tr(
                      namedArgs: {'n': '${index + 1}'},
                    )
                  : v.variableLabels.join(' · ');
              final priceForSelectedList = cubit.selectedPriceListId != null
                  ? v.priceListPrices[cubit.selectedPriceListId]
                  : null;
              return CreateOrderVariantCard(
                variant: v,
                name: name,
                priceForSelectedList: priceForSelectedList,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
