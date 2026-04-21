import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../../services_locator/service_locator.dart';
import '../payment_methods/model/payment_method_model.dart';
import 'cubit/add_new_payment_method_cubit.dart';
import 'widgets/add_new_payment_method_form_widget.dart';

/// Standalone payment method form (e.g. legacy bottom sheet). Prefer inline flow on [PaymentMethodsScreen].
class AddNewPaymentMethodScreen extends StatelessWidget {
  const AddNewPaymentMethodScreen({super.key, this.paymentMethod});
  final PaymentMethodModel? paymentMethod;

  @override
  Widget build(BuildContext context) {
    return CustomPadding(
      child: BlocProvider<AddNewPaymentMethodCubit>(
        create:
            (context) =>
                getIt<AddNewPaymentMethodCubit>()
                  ..setPaymentMethod(paymentMethod),
        child: BlocConsumer<AddNewPaymentMethodCubit, AddNewPaymentMethodState>(
          listener: (context, state) {
            if (state is AddNewPaymentMethodSaved) {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pop<bool>(true);
              final message =
                  paymentMethod != null
                      ? 'add_payment_method_form.update_success'.tr()
                      : 'add_payment_method_form.success'.tr();
              messenger.showSnackBar(SnackBar(content: Text(message)));
            }
          },
          builder: (context, state) {
            if (state is AddNewPaymentMethodLoading) {
              return const CustomLoading();
            }
            if (state is AddNewPaymentMethodError) {
              return CustomFailedWidget(
                message: state.message,
                onRetry:
                    () =>
                        context.read<AddNewPaymentMethodCubit>().dismissError(),
              );
            }
            return DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyE6E9EA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: AddNewPaymentMethodFormWidget(),
              ),
            );
          },
        ),
      ),
    );
  }
}
