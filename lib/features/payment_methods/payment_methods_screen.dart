import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/platform_bottom_sheet.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_button_widget.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../add_new_payment_method/add_new_payment_method_screen.dart';
import 'cubit/payment_methods_cubit.dart';
import 'model/payment_method_model.dart';
import 'widgets/list_of_payment_methods_widget.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  static Future<void> paymentMethodDetails(
    BuildContext context, {
    PaymentMethodModel? paymentMethod,
  }) async {
    final result = await PlatformSheet.show(
      context: context,
      isScrollControlled: false,
      child: AddNewPaymentMethodScreen(paymentMethod: paymentMethod),
    );
    if (result == true) {
      if (!(context.mounted)) return;
      context.read<PaymentMethodsCubit>().getAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'payment_methods'),
      body: CustomPadding(
        child: BlocConsumer<PaymentMethodsCubit, PaymentMethodsState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is PaymentMethodsLoading) {
              return const CustomLoading();
            }
            if (state is PaymentMethodsError ||
                state is PaymentMethodsDeleteError) {
              final message = state is PaymentMethodsError
                  ? state.message
                  : (state as PaymentMethodsDeleteError).message;
              return CustomFailedWidget(
                message: message,
                onRetry: () => context.read<PaymentMethodsCubit>().getAll(),
              );
            }
            final paymentMethods =
                context.read<PaymentMethodsCubit>().paymentMethods;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                CustomButtonWidget(
                  text: 'add_payment_method',
                  onPressed: () async {
                    paymentMethodDetails(context);
                  },
                ),
                Expanded(
                  child: ListOfPaymentMethodsWidget(
                    paymentMethods: paymentMethods,
                    onEdit: (item) =>
                        paymentMethodDetails(context, paymentMethod: item),
                    onDelete: (item) {
                      context
                          .read<PaymentMethodsCubit>()
                          .deleteById(item.id!);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
