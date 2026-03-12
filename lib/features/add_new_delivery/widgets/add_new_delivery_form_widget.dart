import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_button_widget.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../cubit/add_new_delivery_cubit.dart';
import 'branch_dropdown_widget.dart';

class AddNewDeliveryFormWidget extends StatelessWidget {
  const AddNewDeliveryFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddNewDeliveryCubit>();
    return Form(
      key: cubit.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              title: 'add_delivery_form.name'.tr(),
              hint: 'add_delivery_form.name'.tr(),
              controller: cubit.nameController,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'validation.required'.tr()
                  : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              title: 'add_delivery_form.phone_1'.tr(),
              hint: 'add_delivery_form.phone_1'.tr(),
              controller: cubit.phone1Controller,
              isOnlyNumbers: true,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              title: 'add_delivery_form.phone_2'.tr(),
              hint: 'add_delivery_form.phone_2'.tr(),
              isOnlyNumbers: true,
              controller: cubit.phone2Controller,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              title: 'add_delivery_form.address'.tr(),
              hint: 'add_delivery_form.address'.tr(),
              controller: cubit.addressController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              title: 'add_delivery_form.national_id'.tr(),
              hint: 'add_delivery_form.national_id'.tr(),
              isOnlyNumbers: true,

              controller: cubit.nationalIdController,
            ),
            const SizedBox(height: 16),
            BranchDropdownWidget(cubit: cubit),
            const SizedBox(height: 24),
            CustomButtonWidget(
              text: cubit.existingDelivery != null
                  ? 'add_delivery_form.update'
                  : 'add_delivery_form.save',
              onPressed: () => cubit.saveDelivery(),
            ),
          ],
        ),
      ),
    );
  }
}
