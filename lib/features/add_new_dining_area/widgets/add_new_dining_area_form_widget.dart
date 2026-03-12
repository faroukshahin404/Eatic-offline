import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_button_widget.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../cubit/add_new_dining_area_cubit.dart';
import 'dining_area_branch_dropdown_widget.dart';

class AddNewDiningAreaFormWidget extends StatelessWidget {
  const AddNewDiningAreaFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddNewDiningAreaCubit>();
    final isEdit = cubit.diningArea != null;
    return Form(
      key: cubit.formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              title: 'add_dining_area_form.name'.tr(),
              hint: 'add_dining_area_form.name'.tr(),
              controller: cubit.nameController,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'validation.required'.tr()
                  : null,
            ),
            const SizedBox(height: 16),
            DiningAreaBranchDropdownWidget(cubit: cubit),
            const SizedBox(height: 24),
            CustomButtonWidget(
              text: isEdit
                  ? 'add_dining_area_form.update'
                  : 'add_dining_area_form.save',
              onPressed: () => cubit.saveDiningArea(),
            ),
          ],
        ),
      ),
    );
  }
}
