import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../cubit/add_new_product_cubit.dart';

String _priceListLabel(String? name, String? currencyName) {
  if (name != null &&
      name.isNotEmpty &&
      currencyName != null &&
      currencyName.isNotEmpty) {
    return '$name ($currencyName)';
  }
  return name ?? currencyName ?? '-';
}

class AddNewProductVariantsPricesTable extends StatelessWidget {
  const AddNewProductVariantsPricesTable({super.key, required this.cubit});
  final AddNewProductCubit cubit;

  @override
  Widget build(BuildContext context) {
    final rows = cubit.variantTableRows;
    final priceLists = cubit.priceLists;
    final selectedAddons = cubit.addons
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
                                _priceListLabel(pl.name, pl.currencyName),
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
                                SizedBox(
                                  width: 160,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        rows[i].label,
                                        style: AppFonts.styleRegular14.copyWith(
                                          fontFamily: AppFonts.enFamily,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      // TextButton(
                                      //   style: TextButton.styleFrom(
                                      //     padding: const EdgeInsets.symmetric(
                                      //       vertical: 4,
                                      //     ),
                                      //     minimumSize: const Size(0, 28),
                                      //     tapTargetSize:
                                      //         MaterialTapTargetSize.shrinkWrap,
                                      //     foregroundColor: AppColors.primary,
                                      //   ),
                                      //   onPressed: () {
                                      //     // Apply all addons to all variants (read current state at tap time)
                                      //     final currentRows =
                                      //         cubit.variantTableRows;
                                      //     for (final addon in selectedAddons) {
                                      //       final price =
                                      //           currentRows[i]
                                      //               .prices
                                      //               .addonPrices[addon.id] ??
                                      //           0.0;
                                      //       for (
                                      //         var j = 0;
                                      //         j < currentRows.length;
                                      //         j++
                                      //       ) {
                                      //         cubit.setVariantAddonPrice(
                                      //           j,
                                      //           addon.id!,
                                      //           price,
                                      //         );
                                      //       }
                                      //     }
                                      //   },
                                      //   child: Text(
                                      //     'add_product_form.apply_all_addons_to_all'
                                      //         .tr(),
                                      //     style: AppFonts.styleRegular12
                                      //         .copyWith(
                                      //           color: AppColors.primary,
                                      //           decoration:
                                      //               TextDecoration.underline,
                                      //         ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                              ...priceLists.map((pl) {
                                final price =
                                    rows[i].prices.priceListPrices[pl.id] ??
                                    0.0;
                                return DataCell(
                                  SizedBox(
                                    width: 120,
                                    child: _PriceCellWithApply(
                                      key: ValueKey('pl_${i}_${pl.id}'),
                                      value: price,
                                      onChanged: (v) =>
                                          cubit.setVariantPriceListPrice(
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
                                  onChanged: (v) =>
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
                                    child: _PriceCellWithApply(
                                      key: ValueKey('addon_${i}_${addon.id}'),
                                      value: price,
                                      onChanged: (v) =>
                                          cubit.setVariantAddonPrice(
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

/// Price input with "Apply to list" / "Apply addon to all" link below.
/// onApply receives the current value from the text field at tap time.
class _PriceCellWithApply extends StatefulWidget {
  const _PriceCellWithApply({
    super.key,
    required this.value,
    required this.onChanged,
    required this.applyLabel,
    required this.onApply,
  });
  final double value;
  final ValueChanged<double> onChanged;
  final String applyLabel;
  final ValueChanged<double> onApply;

  @override
  State<_PriceCellWithApply> createState() => _PriceCellWithApplyState();
}

class _PriceCellWithApplyState extends State<_PriceCellWithApply> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value == 0 ? '' : widget.value.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
          ],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          ),
          onChanged: (v) {
            final val = double.tryParse(v) ?? 0.0;
            widget.onChanged(val);
          },
        ),
        const SizedBox(height: 2),
        // TextButton(
        //   style: TextButton.styleFrom(
        //     padding: const EdgeInsets.symmetric(vertical: 4),
        //     minimumSize: const Size(0, 28),
        //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        //     foregroundColor: AppColors.primary,
        //   ),
        //   onPressed: () {
        //     final val =
        //         double.tryParse(_controller.text.replaceAll(',', '.')) ?? 0.0;
        //     widget.onChanged(val);
        //     widget.onApply(val);
        //   },
        //   child: Text(
        //     widget.applyLabel,
        //     style: AppFonts.styleRegular12.copyWith(
        //       color: AppColors.primary,
        //       decoration: TextDecoration.underline,
        //       fontSize: 11,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
