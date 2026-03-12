import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/custom_button_widget.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../cubit/add_new_zone_cubit.dart';
import 'branch_dropdown_widget.dart';

class AddNewZoneFormWidget extends StatelessWidget {
  const AddNewZoneFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddNewZoneCubit>();
    return Form(
      key: cubit.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              title: 'add_zone_form.name'.tr(),
              hint: 'add_zone_form.name'.tr(),
              controller: cubit.nameController,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'validation.required'.tr()
                  : null,
            ),
            const SizedBox(height: 16),
            BranchDropdownWidget(cubit: cubit),
            const SizedBox(height: 16),
            CustomTextField(
              title: 'add_zone_form.delivery_cost'.tr(),
              hint: 'add_zone_form.delivery_cost'.tr(),
              controller: cubit.deliveryCostController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
            ),
            const SizedBox(height: 24),
            CustomButtonWidget(
              text: cubit.existingZone != null
                  ? 'add_zone_form.update'
                  : 'add_zone_form.save',
              onPressed: () => cubit.saveZone(),
            ),
          ],
        ),
      ),
    );
  }
}
