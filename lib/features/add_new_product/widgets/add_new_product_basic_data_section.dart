import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../cubit/add_new_product_cubit.dart';

class AddNewProductBasicDataSection extends StatelessWidget {
  const AddNewProductBasicDataSection({super.key, required this.cubit});

  final AddNewProductCubit cubit;

  static const double spacing = 10;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing,
      children: [
        Text(
          'add_product_form.basic_data'.tr(),
          style: AppFonts.styleBold20.copyWith(color: AppColors.oppositeColor),
        ),
        CustomTextField(
          title: 'add_product_form.name'.tr(),
          hint: 'add_product_form.name'.tr(),
          controller: cubit.nameController,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'validation.required'.tr() : null,
        ),
        CustomTextField(
          title: 'add_product_form.name_en'.tr(),
          hint: 'add_product_form.name_en_hint'.tr(),
          controller: cubit.nameEnController,
          // Optional: CustomTextField treats null validator as required by default.
          validator: (_) => null,
        ),
        CustomTextField(
          title: 'add_product_form.description'.tr(),
          hint: 'add_product_form.description'.tr(),
          controller: cubit.descriptionController,
          maxLines: 4,
          validator: (_) => null,
        ),
      ],
    );
  }
}
