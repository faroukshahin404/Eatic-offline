import 'package:flutter/material.dart';

import 'cart_action_buttons.dart';
import 'cart_order_info_widget.dart';

/// Section with Choose Waiter / Choose Table buttons and order info (for Hall / Takeaway).
class CartWaiterTableSection extends StatelessWidget {
  const CartWaiterTableSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      spacing: 16,
      children: [
        CartActionButtons(),
        CartOrderInfoWidget(),
      ],
    );
  }
}
