import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../categories/model/category_model.dart';
import 'category_chip_widget.dart';

class CategoriesRow extends StatelessWidget {
  const CategoriesRow({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelectCategory,
  });

  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final void Function(int?) onSelectCategory;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedCategoryId == null;
            return CategoryChip(
              label: 'home.all'.tr(),
              isSelected: isSelected,
              onTap: () => onSelectCategory(null),
            );
          }
          final category = categories[index - 1];
          final id = category.id;
          final name = category.name ?? '-';
          final isSelected = selectedCategoryId == id;
          return CategoryChip(
            label: name,
            isSelected: isSelected,
            onTap: () => id != null ? onSelectCategory(id) : null,
          );
        },
      ),
    );
  }
}
