import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/core_models/role_model.dart';
import '../../../core/widgets/custom_dropdown.dart';
import '../cubit/add_user_cubit.dart';

class RoleDropdown extends StatelessWidget {
  const RoleDropdown({super.key, required this.cubit});

  final AddUserCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddUserCubit, AddUserState>(
      builder: (context, state) {
        final roles = cubit.roles;
        final selected = cubit.selectedRole;
        if (roles.isEmpty) {
          return const SizedBox.shrink();
        }
        return CustomDropDown<RoleModel>(
          items: roles,
          value: selected,
          onChanged: cubit.setSelectedRole,
          itemLabelBuilder: (role) => role.name,
          label: 'add_user_form.role'.tr(),
          leadingIcon: Icons.badge_rounded,
          validator: (v) => v == null ? 'validation.required'.tr() : null,
        );
      },
    );
  }
}
