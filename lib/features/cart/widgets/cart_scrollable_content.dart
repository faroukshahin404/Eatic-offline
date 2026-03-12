import 'package:flutter/material.dart';

import 'cart_items_list.dart';
import 'cart_order_type_actions.dart';

class CartScrollableContent extends StatelessWidget {
  const CartScrollableContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 16,
          children: [const CartOrderTypeActions(), const CartItemsList()],
        ),
      ),
    );
  }
}
