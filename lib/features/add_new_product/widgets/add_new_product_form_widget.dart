import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/custom_button_widget.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../cubit/add_new_product_cubit.dart';
import 'add_new_product_variants_section.dart';
import 'add_new_product_variants_prices_table.dart';

class AddNewProductFormWidget extends StatelessWidget {
  const AddNewProductFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddNewProductCubit>();
    return Form(
      key: cubit.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'add_product_form.basic_data'.tr(),
              style: AppFonts.styleBold20.copyWith(
                color: AppColors.oppositeColor,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              title: 'add_product_form.name'.tr(),
              hint: 'add_product_form.name'.tr(),
              controller: cubit.nameController,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'validation.required'.tr()
                  : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              title: 'add_product_form.name_en'.tr(),
              hint: 'add_product_form.name_en_hint'.tr(),
              controller: cubit.nameEnController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              title: 'add_product_form.description'.tr(),
              hint: 'add_product_form.description'.tr(),
              controller: cubit.descriptionController,
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: 'add_product_form.categories'.tr()),
            const SizedBox(height: 8),
            BlocBuilder<AddNewProductCubit, AddNewProductState>(
              buildWhen: (_, _) => true,
              builder: (context, _) {
                final c = context.read<AddNewProductCubit>();
                return Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: c.categories
                      .map(
                        (cat) => _CheckboxLabel(
                          key: ValueKey('cat_${cat.id}'),
                          label: cat.name ?? '-',
                          value: c.selectedCategoryIds.contains(cat.id),
                          onChanged: () => c.toggleCategory(cat.id!),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            BlocBuilder<AddNewProductCubit, AddNewProductState>(
              buildWhen: (_, _) => true,
              builder: (context, _) {
                final c = context.read<AddNewProductCubit>();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => c.setHasVariants(!c.hasVariants),
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Checkbox(
                            value: c.hasVariants,
                            onChanged: (v) => c.setHasVariants(v ?? false),
                            activeColor: AppColors.primary,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          Expanded(
                            child: Text(
                              'add_product_form.has_variants'.tr(),
                              style: AppFonts.styleRegular18.copyWith(
                                color: AppColors.oppositeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (c.hasVariants) ...[
                      const SizedBox(height: 16),
                      AddNewProductVariantsSection(cubit: c),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: 'add_product_form.addons'.tr()),
            const SizedBox(height: 8),
            BlocBuilder<AddNewProductCubit, AddNewProductState>(
              buildWhen: (_, _) => true,
              builder: (context, _) {
                final c = context.read<AddNewProductCubit>();
                return Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: c.addons
                      .map(
                        (a) => _CheckboxLabel(
                          key: ValueKey('addon_${a.id}'),
                          label: a.name ?? '-',
                          value: c.selectedAddonIds.contains(a.id),
                          onChanged: () => c.toggleAddon(a.id!),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            BlocBuilder<AddNewProductCubit, AddNewProductState>(
              buildWhen: (_, _) => true,
              builder: (context, _) {
                final c = context.read<AddNewProductCubit>();
                if (!c.hasVariants || c.variantTableRows.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      _SectionTitle(
                        title: 'add_product_form.variants_and_prices'.tr(),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: cubit.priceLists.map((pl) {
                          final price =
                              cubit.productPriceListPrices[pl.id] ?? 0.0;
                          return SizedBox(
                            width: 160,
                            child: _ProductPriceListCell(
                              key: ValueKey('pl_${pl.id}'),
                              label: pl.name ?? pl.currencyName ?? '-',
                              value: price,
                              onChanged: (v) =>
                                  cubit.setProductPriceListPrice(pl.id!, v),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 24),
                    AddNewProductVariantsPricesTable(cubit: c),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),
            CustomButtonWidget(
              text: 'add_product_form.save'.tr(),
              onPressed: () => cubit.saveProduct(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppFonts.styleBold18.copyWith(color: AppColors.oppositeColor),
    );
  }
}

/// Simple checkbox with label only (no chip/container), as in the design.
class _CheckboxLabel extends StatelessWidget {
  const _CheckboxLabel({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: GestureDetector(
        onTap: () => onChanged(),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: value,
                onChanged: (_) => onChanged(),
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppFonts.styleRegular18.copyWith(
                  color: AppColors.oppositeColor,
                  fontFamily: AppFonts.enFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductPriceListCell extends StatefulWidget {
  const _ProductPriceListCell({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<_ProductPriceListCell> createState() => _ProductPriceListCellState();
}

class _ProductPriceListCellState extends State<_ProductPriceListCell> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value == 0 ? '' : widget.value.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant _ProductPriceListCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value == 0 ? '' : widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: AppFonts.styleMedium14.copyWith(
            color: AppColors.oppositeColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          onChanged: (v) {
            final val = double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
            widget.onChanged(val);
          },
        ),
      ],
    );
  }
}
