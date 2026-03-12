import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_button_widget.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../cubit/reset_password_cubit.dart';

class ResetPasswordFormWidget extends StatelessWidget {
  const ResetPasswordFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ResetPasswordCubit>();
    return Form(
      key: cubit.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            title: 'reset_password.current_password'.tr(),
            hint: 'reset_password.current_password'.tr(),
            controller: cubit.currentPasswordController,
            isPassword: true,
            maxLines: 1,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'validation.required'.tr() : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            title: 'reset_password.new_password'.tr(),
            hint: 'reset_password.new_password'.tr(),
            controller: cubit.newPasswordController,
            isPassword: true,
            maxLines: 1,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'validation.required'.tr() : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            title: 'reset_password.confirm_password'.tr(),
            hint: 'reset_password.confirm_password'.tr(),
            controller: cubit.confirmPasswordController,
            isPassword: true,
            maxLines: 1,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'validation.required'.tr();
              if (v != cubit.newPasswordController.text) {
                return 'reset_password.password_mismatch'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          CustomButtonWidget(
            text: 'reset_password.submit'.tr(),
            onPressed: () => cubit.resetPassword(),
          ),
        ],
      ),
    );
  }
}
