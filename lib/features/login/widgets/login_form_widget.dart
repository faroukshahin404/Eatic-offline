import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/custom_assets_image.dart';
import '../../../core/widgets/custom_button_widget.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../cubit/login_cubit.dart';

class LoginFormWidget extends StatelessWidget {
  const LoginFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LoginCubit>();
    return Form(
      key: cubit.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'logo',
              child: CustomAssetImage(image: AppAssets.logo, height: 200),
            ),

            CustomTextField(
              title: 'add_user_form.code'.tr(),
              hint: 'add_user_form.code'.tr(),
              controller: cubit.codeController,
              isOnlyNumbers: true,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'validation.required'.tr()
                  : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              title: 'add_user_form.password'.tr(),
              hint: 'add_user_form.password'.tr(),
              controller: cubit.passwordController,
              isPassword: true,
              maxLines: 1,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'validation.required'.tr()
                  : null,
            ),
            const SizedBox(height: 24),
            CustomButtonWidget(
              height: 50,
              isLoading: cubit.state is LoginLoading,
              text: 'login',
              onPressed: () => cubit.login(),
            ),
          ],
        ),
      ),
    );
  }
}
