import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/pos_crud_ui.dart';
import '../cubit/add_new_restaurant_table_cubit.dart';
import 'restaurant_table_branch_dropdown_widget.dart';
import 'restaurant_table_dining_area_dropdown_widget.dart';

class AddNewRestaurantTableFormWidget extends StatelessWidget {
  const AddNewRestaurantTableFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddNewRestaurantTableCubit, AddNewRestaurantTableState>(
      buildWhen:
          (prev, curr) =>
              curr is AddNewRestaurantTableBranchesLoaded ||
              curr is AddNewRestaurantTableLoadingBranches ||
              curr is AddNewRestaurantTableLoadingDiningAreas ||
              curr is AddNewRestaurantTableDiningAreasLoaded ||
              curr is AddNewRestaurantTableDiningAreasError ||
              curr is AddNewRestaurantTableError,
      builder: (context, state) {
        if (state is AddNewRestaurantTableLoadingBranches) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (state is AddNewRestaurantTableError) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<AddNewRestaurantTableCubit>();
        final isEdit = cubit.restaurantTable != null;
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
                        title: 'add_restaurant_table_form.name'.tr(),
                        hint: 'add_restaurant_table_form.name'.tr(),
                        controller: cubit.nameController,
                        prefix: const Padding(
                          padding: EdgeInsetsDirectional.only(
                            start: 10,
                            end: 8,
                          ),
                          child: Icon(Icons.table_restaurant_outlined),
                        ),
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'validation.required'.tr()
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      RestaurantTableBranchDropdownWidget(cubit: cubit),
                      const SizedBox(height: 16),
                      RestaurantTableDiningAreaDropdownWidget(cubit: cubit),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                PosCrudActionButton(
                  label:
                      (isEdit
                              ? 'add_restaurant_table_form.update'
                              : 'add_restaurant_table_form.save')
                          .tr(),
                  icon: isEdit ? Icons.edit_rounded : Icons.save_outlined,
                  onPressed: () => cubit.saveRestaurantTable(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
