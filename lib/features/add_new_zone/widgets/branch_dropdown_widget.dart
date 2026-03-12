import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_dropdown.dart';
import '../../branches/model/branch_model.dart';
import '../cubit/add_new_zone_cubit.dart';

class BranchDropdownWidget extends StatelessWidget {
  const BranchDropdownWidget({super.key, required this.cubit});

  final AddNewZoneCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddNewZoneCubit, AddNewZoneState>(
      builder: (context, state) {
        return CustomDropDown<BranchModel>(
          items: cubit.branches,
          value: cubit.selectedBranch,
          onChanged: cubit.setSelectedBranch,
          itemLabelBuilder: (b) => b.name,
          label: 'add_zone_form.branch'.tr(),
          validator: (v) => v == null ? 'validation.required'.tr() : null,
        );
      },
    );
  }
}
