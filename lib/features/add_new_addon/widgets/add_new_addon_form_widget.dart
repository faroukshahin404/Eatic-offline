import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/pos_crud_ui.dart';
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
            PosCrudSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    title: 'add_addon_form.name'.tr(),
                    hint: 'add_addon_form.name'.tr(),
                    controller: cubit.nameController,
                    prefix: const Padding(
                      padding: EdgeInsetsDirectional.only(start: 10, end: 8),
                      child: Icon(Icons.label_outline_rounded),
                    ),
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'validation.required'.tr()
                                : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    title: 'add_addon_form.price'.tr(),
                    hint: 'add_addon_form.price'.tr(),
                    controller: cubit.priceController,
                    prefix: const Padding(
                      padding: EdgeInsetsDirectional.only(start: 10, end: 8),
                      child: Icon(Icons.payments_outlined),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PosCrudActionButton(
              label:
                  (isEdit
                          ? 'add_addon_form.update'
                          : 'add_addon_form.save')
                      .tr(),
              icon: isEdit ? Icons.edit_rounded : Icons.save_outlined,
              onPressed: () => cubit.saveAddon(),
            ),
          ],
        ),
      ),
    );
  }
}
