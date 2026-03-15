import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../cubit/add_new_product_cubit.dart';
import 'add_new_product_variants_section.dart';

class AddNewProductHasVariantsSection extends StatelessWidget {
  const AddNewProductHasVariantsSection({super.key, required this.cubit});

  final AddNewProductCubit cubit;

  static const double spacing = 16;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: spacing,
      children: [
        GestureDetector(
          onTap: () => cubit.setHasVariants(!cubit.hasVariants),
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Checkbox(
                value: cubit.hasVariants,
                onChanged: (v) => cubit.setHasVariants(v ?? false),
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
        if (cubit.hasVariants) AddNewProductVariantsSection(cubit: cubit),
      ],
    );
  }
}
