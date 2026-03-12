import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_button_widget.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../cubit/add_new_payment_method_cubit.dart';

class AddNewPaymentMethodFormWidget extends StatelessWidget {
  const AddNewPaymentMethodFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddNewPaymentMethodCubit>();
    final isEdit = cubit.paymentMethod != null;
    return Form(
      key: cubit.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            title: 'add_payment_method_form.name'.tr(),
            hint: 'add_payment_method_form.name'.tr(),
            controller: cubit.nameController,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'validation.required'.tr() : null,
          ),
          const SizedBox(height: 24),
          CustomButtonWidget(
            text: isEdit ? 'add_payment_method_form.update' : 'add_payment_method_form.save',
            onPressed: () => cubit.savePaymentMethod(),
          ),
        ],
      ),
    );
  }
}
