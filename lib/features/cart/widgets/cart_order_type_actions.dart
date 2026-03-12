import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_button_widget.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import 'cart_waiter_table_section.dart';

const int deliveryOrderTypeIndex = 2;

class CartOrderTypeActions extends StatelessWidget {
  const CartOrderTypeActions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      buildWhen: (p, c) => p.selectedOrderTypeIndex != c.selectedOrderTypeIndex,
      builder: (context, state) {
        if (state.selectedOrderTypeIndex == deliveryOrderTypeIndex) {
          return CustomButtonWidget(
            text: 'cart.add_user_info'.tr(),
            onPressed: () {},
          );
        }
        return const CartWaiterTableSection();
      },
    );
  }
}
