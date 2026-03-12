import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_button_widget.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../cubit/add_customer_cubit.dart';
import 'address_entries_list_widget.dart';

class AddCustomerFormWidget extends StatelessWidget {
  const AddCustomerFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddCustomerCubit>();

    return Form(
      key: cubit.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              title: 'customers.name'.tr(),
              hint: 'customers.name'.tr(),
              controller: cubit.nameController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              title: 'customers.phone'.tr(),
              hint: 'customers.phone'.tr(),
              controller: cubit.phoneController,
              isOnlyNumbers: true,
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'validation.required'.tr();
                if (!AddCustomerCubit.isNumber(v)) {
                  return 'validation.phone_number'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              title: 'customers.second_phone'.tr(),
              hint: 'customers.second_phone'.tr(),
              controller: cubit.secondPhoneController,
              isOnlyNumbers: true,
              validator: (v) {
                if (v != null &&
                    v.trim().isNotEmpty &&
                    !AddCustomerCubit.isNumber(v)) {
                  return 'validation.phone_number'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'customers.add_new_address'.tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => cubit.addAddress(),
                  icon: const Icon(Icons.add),
                  label: Text('customers.add_new_address'.tr()),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const AddressEntriesListWidget(),
            const SizedBox(height: 12),

            CustomButtonWidget(
              text: 'customers.save'.tr(),
              onPressed: () => cubit.save(),
            ),
          ],
        ),
      ),
    );
  }
}
