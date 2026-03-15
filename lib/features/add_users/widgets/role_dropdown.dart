import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/core_models/role_model.dart';
import '../cubit/add_user_cubit.dart';

class RoleDropdown extends StatelessWidget {
  const RoleDropdown({super.key, required this.cubit});

  final AddUserCubit cubit;

  static InputDecoration _dropdownDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.greyE6E9EA),
        borderRadius: BorderRadius.circular(15),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.greyE6E9EA),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.mainColor),
        borderRadius: BorderRadius.circular(15),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(15),
      ),
      filled: true,
      fillColor: AppColors.fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddUserCubit, AddUserState>(
      builder: (context, state) {
        final roles = cubit.roles;
        final selected = cubit.selectedRole;
        if (roles.isEmpty) {
          return const SizedBox.shrink();
        }
        final value = selected ?? roles.first;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'add_user_form.role'.tr(),
              textAlign: TextAlign.right,
              style: AppFonts.styleMedium18.copyWith(
                color: AppColors.oppositeColor,
              ),
            ),
            const SizedBox(height: 5),
            DropdownButtonFormField<RoleModel>(
              value: value,
              decoration: _dropdownDecoration(),
              dropdownColor: AppColors.fillColor,
              style: AppFonts.styleRegular18.copyWith(
                color: AppColors.oppositeColor,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.greyA4ACAD,
              ),
              isExpanded: true,
              alignment: Alignment.centerRight,
              items: roles
                  .map(
                    (r) => DropdownMenuItem<RoleModel>(
                      value: r,
                      child: Text(
                        r.name,
                        style: AppFonts.styleRegular18.copyWith(
                          fontFamily: AppFonts.enFamily,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (RoleModel? value) => cubit.setSelectedRole(value),
              validator: (RoleModel? v) =>
                  v == null ? 'validation.required'.tr() : null,
            ),
          ],
        );
      },
    );
  }
}
