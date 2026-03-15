import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../cubit/add_new_product_cubit.dart';
import 'add_new_product_price_list_cell.dart';
import 'add_new_product_section_title.dart';
import 'add_new_product_variants_prices_table.dart';

class AddNewProductVariantsAndPricesSection extends StatelessWidget {
  const AddNewProductVariantsAndPricesSection({super.key, required this.cubit});

  final AddNewProductCubit cubit;

  @override
  Widget build(BuildContext context) {
    if (!cubit.hasVariants || cubit.variantTableRows.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: [
          AddNewProductSectionTitle(
            title: 'add_product_form.variants_and_prices'.tr(),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children:
                cubit.priceLists.map((pl) {
                  final price = cubit.productPriceListPrices[pl.id] ?? 0.0;
                  return SizedBox(
                    width: 160,
                    child: AddNewProductPriceListCell(
                      key: ValueKey('pl_${pl.id}'),
                      label: pl.name ?? pl.currencyName ?? '-',
                      value: price,
                      onChanged:
                          (v) => cubit.setProductPriceListPrice(pl.id!, v),
                    ),
                  );
                }).toList(),
          ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: AddNewProductVariantsPricesTable(cubit: cubit),
    );
  }
}
