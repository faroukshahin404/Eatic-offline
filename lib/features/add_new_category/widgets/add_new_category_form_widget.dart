import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_button_widget.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../cubit/add_new_category_cubit.dart';
import 'parent_category_dropdown_widget.dart';

class AddNewCategoryFormWidget extends StatelessWidget {
  const AddNewCategoryFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddNewCategoryCubit>();
    final isEdit = cubit.category != null;
    return Form(
      key: cubit.formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              title: 'add_category_form.name'.tr(),
              hint: 'add_category_form.name'.tr(),
              controller: cubit.nameController,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'validation.required'.tr()
                  : null,
            ),
            const SizedBox(height: 16),
            ParentCategoryDropdownWidget(cubit: cubit),
            const SizedBox(height: 24),
            CustomButtonWidget(
              text: isEdit
                  ? 'add_category_form.update'
                  : 'add_category_form.save',
              onPressed: () => cubit.saveCategory(),
            ),
          ],
        ),
      ),
    );
  }
}
