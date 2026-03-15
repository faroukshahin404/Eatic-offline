import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_button_widget.dart';
import '../cubit/add_new_product_cubit.dart';
import 'add_new_product_addons_section.dart';
import 'add_new_product_basic_data_section.dart';
import 'add_new_product_categories_section.dart';
import 'add_new_product_has_variants_section.dart';
import 'add_new_product_variants_and_prices_section.dart';

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
          spacing: 20,
          children: [
            AddNewProductBasicDataSection(cubit: cubit),
            AddNewProductCategoriesSection(cubit: cubit),
            AddNewProductHasVariantsSection(cubit: cubit),
            AddNewProductAddonsSection(cubit: cubit),
            AddNewProductVariantsAndPricesSection(cubit: cubit),
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
