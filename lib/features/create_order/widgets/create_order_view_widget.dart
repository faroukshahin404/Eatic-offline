import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/custom_button_widget.dart';
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
        CustomButtonWidget(
          text: 'create_order.add_to_order'.tr(),
          onPressed: () {
            cubit.requestValidation();
            if (!cubit.areAllVariantsSelected) {
              cubit.notifyValidationFailed();
              return;
            }
            final orderLine = cubit.buildOrderLineModel();
            if (orderLine != null) {
              cubit.clearAllSelection();
            }
          },
        ),
      ],
    );
  }
}
