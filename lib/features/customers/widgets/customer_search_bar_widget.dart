import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_button_widget.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../cubit/customer_search_cubit.dart';

class CustomerSearchBarWidget extends StatelessWidget {
  const CustomerSearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CustomerSearchCubit>();
    return Column(
      spacing: 16,
      children: [
        Row(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: CustomTextField(
                title: 'customers.name'.tr(),
                hint: 'customers.name'.tr(),
                controller: cubit.nameController,
              ),
            ),
            Expanded(
              child: CustomTextField(
                title: 'customers.phone'.tr(),
                hint: 'customers.phone'.tr(),
                controller: cubit.phoneController,
                keyboardType: TextInputType.phone,
                isOnlyNumbers: true,
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        CustomButtonWidget(
          text: 'customers.search'.tr(),
          width: 100,
          onPressed: () => cubit.runSearch(),
        ),
      ],
    );
  }
}
