import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/custom_button_widget.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../cubit/add_new_addon_cubit.dart';

class AddNewAddonFormWidget extends StatelessWidget {
  const AddNewAddonFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddNewAddonCubit>();
    final isEdit = cubit.addon != null;
    return Form(
      key: cubit.formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              title: 'add_addon_form.name'.tr(),
              hint: 'add_addon_form.name'.tr(),
              controller: cubit.nameController,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'validation.required'.tr()
                  : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              title: 'add_addon_form.price'.tr(),
              hint: 'add_addon_form.price'.tr(),
              controller: cubit.priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
            ),
            const SizedBox(height: 24),
            CustomButtonWidget(
              text: isEdit
                  ? 'add_addon_form.update'
                  : 'add_addon_form.save',
              onPressed: () => cubit.saveAddon(),
            ),
          ],
        ),
      ),
    );
  }
}
