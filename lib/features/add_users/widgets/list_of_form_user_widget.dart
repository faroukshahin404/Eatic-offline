import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/pos_crud_ui.dart';
import '../../../routes/app_paths.dart';
import '../cubit/add_user_cubit.dart';
import 'branch_dropdown.dart';
import 'role_dropdown.dart';
import '../../users/model/user_model.dart';

class ListFormUserWidget extends StatelessWidget {
  const ListFormUserWidget({super.key, this.userId});
  final int? userId;

  static String get _now => DateTime.now().toIso8601String();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddUserCubit>();
    final isEdit = cubit.currentUser != null;

    return Form(
      key: cubit.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PosCrudSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    title: 'add_user_form.code'.tr(),
                    hint: 'add_user_form.code'.tr(),
                    controller: cubit.codeController,
                    isOnlyNumbers: true,
                    prefix: const Padding(
                      padding: EdgeInsetsDirectional.only(start: 10, end: 8),
                      child: Icon(Icons.badge_outlined),
                    ),
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'validation.required'.tr()
                                : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    title: 'add_user_form.name'.tr(),
                    hint: 'add_user_form.name'.tr(),
                    controller: cubit.nameController,
                    prefix: const Padding(
                      padding: EdgeInsetsDirectional.only(start: 10, end: 8),
                      child: Icon(Icons.person_outline_rounded),
                    ),
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'validation.required'.tr()
                                : null,
                  ),
                  if (userId == null) ...[
                    const SizedBox(height: 16),
                    CustomTextField(
                      title: 'add_user_form.password'.tr(),
                      hint: 'add_user_form.password'.tr(),
                      controller: cubit.passwordController,
                      maxLines: 1,
                      isPassword: true,
                      prefix: const Padding(
                        padding: EdgeInsetsDirectional.only(start: 10, end: 8),
                        child: Icon(Icons.lock_outline_rounded),
                      ),
                      validator:
                          (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'validation.required'.tr()
                                  : null,
                    ),
                  ],
                  const SizedBox(height: 16),
                  RoleDropdown(cubit: cubit),
                  const SizedBox(height: 16),
                  BranchDropdown(cubit: cubit),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PosCrudActionButton(
              label:
                  (isEdit ? 'add_user_form.update' : 'add_user_form.save').tr(),
              icon: isEdit ? Icons.edit_rounded : Icons.save_outlined,
              onPressed: () => _submit(context, cubit, isEdit),
            ),
            if (userId != null) ...[
              const SizedBox(height: 16),
              PosCrudActionButton(
                label: 'reset_password.title'.tr(),
                icon: Icons.lock_reset_rounded,
                isPrimary: false,
                backgroundColor: const Color(0xFFFFF1F1),
                foregroundColor: AppColors.validationError,
                borderColor: const Color(0xFFFFD9D9),
                onPressed: () {
                  context.push(AppPaths.resetPassword, extra: userId);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext context, AddUserCubit cubit, bool isEdit) {
    if (cubit.formKey.currentState?.validate() != true) return;

    final code = cubit.codeController.text.trim();
    final name = cubit.nameController.text.trim();
    final password = cubit.passwordController.text.trim();
    final roleId = cubit.selectedRoleId;
    final branchId = cubit.selectedBranchId;

    if (isEdit && cubit.currentUser != null) {
      final user = cubit.currentUser!.copyWith(
        code: code,
        name: name.isEmpty ? null : name,
        password: password.isEmpty ? null : password,
        roleId: roleId,
        branchId: branchId,
        updatedAt: _now,
      );
      cubit.editUser(user);
    } else {
      final user = UserModel(
        code: code,
        name: name.isEmpty ? null : name,
        password: password.isEmpty ? null : password,
        roleId: roleId,
        branchId: branchId,
        createdAt: _now,
        updatedAt: _now,
      );
      cubit.addUser(user);
    }
  }
}
