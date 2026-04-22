import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../_main/cubit/main_cubit.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import 'cart_delivery_customer_section.dart';
import 'cart_waiter_table_section.dart';

class CartOrderTypeActions extends StatelessWidget {
  const CartOrderTypeActions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      buildWhen:
          (p, c) =>
              p.selectedOrderTypeIndex != c.selectedOrderTypeIndex ||
              p.selectedCustomer != c.selectedCustomer,
      builder: (context, state) {
        if (state.selectedOrderTypeIndex == 1 ||
            state.selectedOrderTypeIndex == 2) {
          return CartDeliveryCustomerSection(
            selectedCustomer: state.selectedCustomer,
          );
        }
        if (context.read<MainCubit>().customerInfoPanelVisible) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<MainCubit>().setCustomerInfoPanelVisible(false);
            }
          });
        }
        return const CartWaiterTableSection();
      },
    );
  }
}
