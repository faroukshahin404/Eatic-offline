import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/pos_crud_ui.dart';
import '../cubit/add_new_currency_cubit.dart';

class AddNewCurrencyFormWidget extends StatelessWidget {
  const AddNewCurrencyFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddNewCurrencyCubit>();
    final isEdit = cubit.existingCurrency != null;

    return Form(
      key: cubit.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PosCrudSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    title: 'add_currency_form.name'.tr(),
                    hint: 'add_currency_form.name'.tr(),
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
                    title: 'add_currency_form.code'.tr(),
                    hint: 'add_currency_form.code'.tr(),
                    controller: cubit.codeController,
                    prefix: const Padding(
                      padding: EdgeInsetsDirectional.only(start: 10, end: 8),
                      child: Icon(Icons.tag_outlined),
                    ),
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'validation.required'.tr()
                                : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    title: 'add_currency_form.symbol'.tr(),
                    hint: 'add_currency_form.symbol'.tr(),
                    controller: cubit.symbolController,
                    prefix: const Padding(
                      padding: EdgeInsetsDirectional.only(start: 10, end: 8),
                      child: Icon(Icons.attach_money_rounded),
                    ),
                    validator: (_) => null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PosCrudActionButton(
              label:
                  (isEdit
                          ? 'add_currency_form.update'
                          : 'add_currency_form.save')
                      .tr(),
              icon: isEdit ? Icons.edit_rounded : Icons.save_outlined,
              onPressed: () => cubit.saveCurrency(),
            ),
          ],
        ),
      ),
    );
  }
}
