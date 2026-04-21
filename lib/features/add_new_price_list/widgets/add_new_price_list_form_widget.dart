import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_dropdown.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/pos_crud_ui.dart';
import '../../currencies/model/currency_model.dart';
import '../cubit/add_new_price_list_cubit.dart';

class AddNewPriceListFormWidget extends StatelessWidget {
  const AddNewPriceListFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddNewPriceListCubit, AddNewPriceListState>(
      buildWhen: (prev, curr) => curr is AddNewPriceListReady,
      builder: (context, state) {
        final cubit = context.read<AddNewPriceListCubit>();
        final isEdit = cubit.priceList != null;
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
                        title: 'add_price_list_form.name'.tr(),
                        hint: 'add_price_list_form.name'.tr(),
                        controller: cubit.nameController,
                        prefix: const Padding(
                          padding: EdgeInsetsDirectional.only(
                            start: 10,
                            end: 8,
                          ),
                          child: Icon(Icons.list_alt_rounded),
                        ),
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'validation.required'.tr()
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      CustomDropDown<CurrencyModel>(
                        items: cubit.currencies,
                        value: cubit.selectedCurrency,
                        onChanged: cubit.selectCurrency,
                        itemLabelBuilder: (c) => c.name ?? '-',
                        label: 'add_price_list_form.currency'.tr(),
                        validator:
                            (v) =>
                                v == null
                                    ? 'validation.required'.tr()
                                    : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                PosCrudActionButton(
                  label:
                      (isEdit
                              ? 'add_price_list_form.update'
                              : 'add_price_list_form.save')
                          .tr(),
                  icon: isEdit ? Icons.edit_rounded : Icons.save_outlined,
                  onPressed: () => cubit.savePriceList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
