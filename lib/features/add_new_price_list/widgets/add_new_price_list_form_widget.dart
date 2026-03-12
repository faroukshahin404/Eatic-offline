import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_button_widget.dart';
import '../../../core/widgets/custom_dropdown.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../currencies/model/currency_model.dart';
import '../cubit/add_new_price_list_cubit.dart';

class AddNewPriceListFormWidget extends StatelessWidget {
  const AddNewPriceListFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddNewPriceListCubit>();
    return Form(
      key: cubit.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            title: 'add_price_list_form.name'.tr(),
            hint: 'add_price_list_form.name'.tr(),
            controller: cubit.nameController,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'validation.required'.tr() : null,
          ),
          const SizedBox(height: 20),
          CustomDropDown<CurrencyModel>(
            items: cubit.currencies,
            value: cubit.selectedCurrency,
            onChanged: cubit.selectCurrency,
            itemLabelBuilder: (c) => c.name ?? '-',
            label: 'add_price_list_form.currency'.tr(),
            validator: (v) => v == null ? 'validation.required'.tr() : null,
          ),
          const SizedBox(height: 24),
          CustomButtonWidget(
            text: cubit.priceList != null
                ? 'add_price_list_form.update'.tr()
                : 'add_price_list_form.save'.tr(),
            onPressed: () => cubit.savePriceList(),
          ),
        ],
      ),
    );
  }
}
