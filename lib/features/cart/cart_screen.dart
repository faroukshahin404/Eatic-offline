import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'widgets/cart_header.dart';
import 'widgets/cart_items_list.dart';
import 'widgets/cart_order_type_actions.dart';
import 'widgets/cart_order_type_selector.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.greyE6E9EA),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 16,
            children: [
              const CartHeader(),
              const CartOrderTypeSelector(),
              const CartOrderTypeActions(),
              const CartItemsList(),
            ],
          ),
        ),
      ),
    );
  }
}
