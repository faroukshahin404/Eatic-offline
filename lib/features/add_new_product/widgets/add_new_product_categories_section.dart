import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../cubit/add_new_product_cubit.dart';
import 'add_new_product_checkbox_label.dart';
import 'add_new_product_section_title.dart';

class AddNewProductCategoriesSection extends StatelessWidget {
  const AddNewProductCategoriesSection({super.key, required this.cubit});

  final AddNewProductCubit cubit;

  static const double spacing = 8;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing,
      children: [
        AddNewProductSectionTitle(title: 'add_product_form.categories'.tr()),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: cubit.categories
              .map(
                (cat) => AddNewProductCheckboxLabel(
                  key: ValueKey('cat_${cat.id}'),
                  label: cat.name ?? '-',
                  value: cubit.selectedCategoryIds.contains(cat.id),
                  onChanged: () => cubit.toggleCategory(cat.id!),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
