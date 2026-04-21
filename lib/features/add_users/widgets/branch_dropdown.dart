import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/custom_dropdown.dart';
import '../../branches/model/branch_model.dart';
import '../cubit/add_user_cubit.dart';

class BranchDropdown extends StatelessWidget {
  const BranchDropdown({super.key, required this.cubit});

  final AddUserCubit cubit;

  @override
  Widget build(BuildContext context) {
    final isCashier = cubit.selectedRole?.name.toLowerCase() == 'cashier';
    if (!isCashier) {
      return const SizedBox.shrink();
    }
    final branches = cubit.branches;
    if (branches.isEmpty) {
      return const SizedBox.shrink();
    }
    return CustomDropDown<BranchModel?>(
      items: [null, ...branches],
      value: cubit.selectedBranch,
      onChanged: cubit.setSelectedBranch,
      itemLabelBuilder: (b) => b?.name ?? 'add_user_form.branch_hint'.tr(),
      label: 'add_user_form.branch'.tr(),
      leadingIcon: Icons.store_mall_directory_outlined,
      validator: (v) => v == null ? 'validation.required'.tr() : null,
      hideWhenEmpty: true,
    );
  }
}
