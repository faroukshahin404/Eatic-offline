import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../categories/model/category_model.dart';
import '../cubit/add_new_category_cubit.dart';

class ParentCategoryDropdownWidget extends StatelessWidget {
  const ParentCategoryDropdownWidget({super.key, required this.cubit});

  final AddNewCategoryCubit cubit;

  static InputDecoration _dropdownDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.greyE6E9EA),
        borderRadius: BorderRadius.circular(15),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.greyE6E9EA),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.mainColor),
        borderRadius: BorderRadius.circular(15),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(15),
      ),
      filled: true,
      fillColor: AppColors.fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddNewCategoryCubit, AddNewCategoryState>(
      builder: (context, state) {
        final options = cubit.parentDropdownCategories;
        final selected = cubit.selectedParent;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'add_category_form.parent_category'.tr(),
              textAlign: TextAlign.start,
              style: AppFonts.styleMedium18.copyWith(
                color: AppColors.oppositeColor,
              ),
            ),
            const SizedBox(height: 5),
            DropdownButtonFormField<CategoryModel?>(
              value: selected,
              decoration: _dropdownDecoration(),
              dropdownColor: AppColors.fillColor,
              style: AppFonts.styleRegular18.copyWith(
                color: AppColors.oppositeColor,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.greyA4ACAD,
              ),
              isExpanded: true,
              items: [
                DropdownMenuItem<CategoryModel?>(
                  value: null,
                  child: Text(
                    'add_category_form.no_parent'.tr(),
                    style: AppFonts.styleRegular18.copyWith(
                      fontFamily: AppFonts.enFamily,
                    ),
                  ),
                ),
                ...options.map(
                  (c) => DropdownMenuItem<CategoryModel?>(
                    value: c,
                    child: Text(
                      c.name ?? '-',
                      style: AppFonts.styleRegular18.copyWith(
                        fontFamily: AppFonts.enFamily,
                      ),
                    ),
                  ),
                ),
              ],
              onChanged: (CategoryModel? value) =>
                  cubit.setSelectedParent(value),
            ),
          ],
        );
      },
    );
  }
}
