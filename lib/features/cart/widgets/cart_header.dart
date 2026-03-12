import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import 'cart_add_new_order_button.dart';
import 'cart_close_custody_button.dart';

/// Cart header: Add New Order and Close Custody buttons.
class CartHeader extends StatelessWidget {
  const CartHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      buildWhen: (p, c) => p.hasOpenCustody != c.hasOpenCustody,
      builder: (context, state) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CartAddNewOrderButton(),
              const SizedBox(width: 12),
              CartCloseCustodyButton(hasOpenCustody: state.hasOpenCustody),
            ],
          ),
        );
      },
    );
  }
}
