import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../cubit/add_new_product_cubit.dart';
import 'add_new_product_price_cell_with_apply.dart';
import 'add_new_product_variant_label_cell.dart';
import 'add_new_product_variants_prices_table_utils.dart';

class AddNewProductVariantsPricesTable extends StatelessWidget {
  const AddNewProductVariantsPricesTable({super.key, required this.cubit});
  final AddNewProductCubit cubit;

  @override
  Widget build(BuildContext context) {
    final rows = cubit.variantTableRows;
    final priceLists = cubit.priceLists;
    final selectedAddons =
        cubit.addons
            .where((a) => cubit.selectedAddonIds.contains(a.id))
            .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final fullWidth = constraints.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'add_product_form.variants_and_prices'.tr(),
              style: AppFonts.styleBold18.copyWith(
                color: AppColors.oppositeColor,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: fullWidth,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: fullWidth),
                    child: DataTable(
                      dataRowMinHeight: 64,
                      dataRowMaxHeight: 80,
                      columnSpacing: 20,
                      horizontalMargin: 16,
                      headingRowColor: WidgetStateProperty.all(
                        AppColors.secondary,
                      ),
                      columns: [
                        DataColumn(
                          label: Text(
                            'add_product_form.variant'.tr(),
                            style: AppFonts.styleBold16,
                          ),
                        ),
                        ...priceLists.map(
                          (pl) => DataColumn(
                            label: SizedBox(
                              width: 120,
                              child: Text(
                                priceListLabel(pl.name, pl.currencyName),
                                style: AppFonts.styleBold14,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'add_product_form.active'.tr(),
                            style: AppFonts.styleBold16,
                          ),
                        ),
                        ...selectedAddons.map(
                          (a) => DataColumn(
                            label: SizedBox(
                              width: 120,
                              child: Text(
                                a.name ?? '-',
                                style: AppFonts.styleBold14,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                      rows: [
                        for (var i = 0; i < rows.length; i++)
                          DataRow(
                            cells: [
                              DataCell(
                                AddNewProductVariantLabelCell(
                                  label: rows[i].label,
                                ),
                              ),
                              ...priceLists.map((pl) {
                                final price =
                                    rows[i].prices.priceListPrices[pl.id] ??
                                    0.0;
                                return DataCell(
                                  SizedBox(
                                    width: 120,
                                    child: AddNewProductPriceCellWithApply(
                                      key: ValueKey('pl_${i}_${pl.id}'),
                                      value: price,
                                      onChanged:
                                          (v) => cubit.setVariantPriceListPrice(
                                            i,
                                            pl.id!,
                                            v,
                                          ),
                                      applyLabel:
                                          'add_product_form.apply_to_list'.tr(),
                                      onApply: (double val) {
                                        for (var j = 0; j < rows.length; j++) {
                                          cubit.setVariantPriceListPrice(
                                            j,
                                            pl.id!,
                                            val,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                );
                              }),
                              DataCell(
                                Checkbox(
                                  value: rows[i].prices.isActive,
                                  onChanged:
                                      (v) =>
                                          cubit.setVariantActive(i, v ?? true),
                                  activeColor: AppColors.primary,
                                ),
                              ),
                              ...selectedAddons.map((addon) {
                                final price =
                                    rows[i].prices.addonPrices[addon.id] ?? 0.0;
                                return DataCell(
                                  SizedBox(
                                    width: 120,
                                    child: AddNewProductPriceCellWithApply(
                                      key: ValueKey('addon_${i}_${addon.id}'),
                                      value: price,
                                      onChanged:
                                          (v) => cubit.setVariantAddonPrice(
                                            i,
                                            addon.id!,
                                            v,
                                          ),
                                      applyLabel:
                                          'add_product_form.apply_addon_to_all'
                                              .tr(),
                                      onApply: (double val) {
                                        for (var j = 0; j < rows.length; j++) {
                                          cubit.setVariantAddonPrice(
                                            j,
                                            addon.id!,
                                            val,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
