import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_button_widget.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../cubit/add_new_currency_cubit.dart';

class AddNewCurrencyFormWidget extends StatelessWidget {
  const AddNewCurrencyFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddNewCurrencyCubit>();
    return Form(
      key: cubit.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              title: 'add_currency_form.name'.tr(),
              hint: 'add_currency_form.name'.tr(),
              controller: cubit.nameController,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'validation.required'.tr()
                  : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              title: 'add_currency_form.code'.tr(),
              hint: 'add_currency_form.code'.tr(),
              controller: cubit.codeController,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'validation.required'.tr()
                  : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              title: 'add_currency_form.symbol'.tr(),
              hint: 'add_currency_form.symbol'.tr(),
              controller: cubit.symbolController,
            ),
            const SizedBox(height: 24),
            CustomButtonWidget(
              text: cubit.existingCurrency != null
                  ? 'add_currency_form.update'
                  : 'add_currency_form.save',
              onPressed: () => cubit.saveCurrency(),
            ),
          ],
        ),
      ),
    );
  }
}
