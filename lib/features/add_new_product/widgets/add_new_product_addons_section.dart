import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../cubit/add_new_product_cubit.dart';
import 'add_new_product_checkbox_label.dart';
import 'add_new_product_section_title.dart';

class AddNewProductAddonsSection extends StatelessWidget {
  const AddNewProductAddonsSection({super.key, required this.cubit});

  final AddNewProductCubit cubit;

  static const double spacing = 8;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing,
      children: [
        AddNewProductSectionTitle(title: 'add_product_form.addons'.tr()),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: cubit.addons
              .map(
                (a) => AddNewProductCheckboxLabel(
                  key: ValueKey('addon_${a.id}'),
                  label: a.name ?? '-',
                  value: cubit.selectedAddonIds.contains(a.id),
                  onChanged: () => cubit.toggleAddon(a.id!),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
