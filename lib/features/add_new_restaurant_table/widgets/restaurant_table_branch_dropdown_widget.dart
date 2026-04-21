import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_dropdown.dart';
import '../../branches/model/branch_model.dart';
import '../cubit/add_new_restaurant_table_cubit.dart';

class RestaurantTableBranchDropdownWidget extends StatelessWidget {
  const RestaurantTableBranchDropdownWidget({
    super.key,
    required this.cubit,
  });

  final AddNewRestaurantTableCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddNewRestaurantTableCubit, AddNewRestaurantTableState>(
      builder: (context, state) {
        return CustomDropDown<BranchModel>(
          items: cubit.branches,
          value: cubit.selectedBranch,
          onChanged: cubit.setSelectedBranch,
          itemLabelBuilder: (b) => b.name,
          label: 'add_restaurant_table_form.branch'.tr(),
          leadingIcon: Icons.store_mall_directory_outlined,
          validator: (v) => v == null ? 'validation.required'.tr() : null,
        );
      },
    );
  }
}
