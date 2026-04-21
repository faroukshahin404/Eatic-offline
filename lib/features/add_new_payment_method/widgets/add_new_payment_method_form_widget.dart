import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/pos_crud_ui.dart';
import '../cubit/add_new_payment_method_cubit.dart';

class AddNewPaymentMethodFormWidget extends StatelessWidget {
  const AddNewPaymentMethodFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddNewPaymentMethodCubit>();
    final isEdit = cubit.paymentMethod != null;

    return Form(
      key: cubit.formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PosCrudSectionCard(
              child: CustomTextField(
                title: 'add_payment_method_form.name'.tr(),
                hint: 'add_payment_method_form.name'.tr(),
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
            ),
            const SizedBox(height: 16),
            PosCrudActionButton(
              label:
                  (isEdit
                          ? 'add_payment_method_form.update'
                          : 'add_payment_method_form.save')
                      .tr(),
              icon: isEdit ? Icons.edit_rounded : Icons.save_outlined,
              onPressed: () => cubit.savePaymentMethod(),
            ),
          ],
        ),
      ),
    );
  }
}
