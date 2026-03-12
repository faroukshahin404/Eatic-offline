import 'package:flutter/material.dart';

import 'cart_choose_table_button.dart';
import 'cart_choose_waiter_button.dart';

/// Row of Choose Waiter and Choose Table buttons.
class CartActionButtons extends StatelessWidget {
  const CartActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CartChooseWaiterButton(),
        SizedBox(width: 12),
        CartChooseTableButton(),
      ],
    );
  }
}
