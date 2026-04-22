import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_button_widget.dart';
import '../../../routes/app_paths.dart';
import '../../_main/cubit/main_cubit.dart';
import '../../cart/cubit/cart_cubit.dart';
import '../cubit/create_order_cubit.dart';
import 'create_order_body_widget.dart';

class CreateOrderViewWidget extends StatelessWidget {
  const CreateOrderViewWidget({super.key, required this.cubit});
  final CreateOrderCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: CreateOrderBodyWidget(cubit: cubit)),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 50),
            child: SizedBox(
              width: double.infinity,
              child: CustomButtonWidget(
                text: 'create_order.add_to_order'.tr(),
                onPressed: () {
                  cubit.requestValidation();
                  if (!cubit.areAllVariantsSelected) {
                    cubit.notifyValidationFailed();
                    return;
                  }
                  final orderLine = cubit.buildOrderLineModel();
                  if (orderLine != null) {
                    final messenger = ScaffoldMessenger.of(context);
                    final addedMessage = 'create_order.added_to_order'.tr();
                    context.read<CartCubit>().addItem(orderLine);
                    if (!context.mounted) return;
                    context.read<MainCubit>().setCurrentScreen(
                      screen: AppPaths.home,
                    );
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(addedMessage),
                          backgroundColor: Colors.green.shade700,
                        ),
                      );
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
