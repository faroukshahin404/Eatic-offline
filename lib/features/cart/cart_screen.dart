import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_padding.dart';
import 'widgets/cart_action_buttons.dart';
import 'widgets/cart_header.dart';
import 'widgets/cart_items_list.dart';
import 'widgets/cart_order_info_widget.dart';
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
            children: [
              const CartHeader(),
              const SizedBox(height: 20),
              const CartOrderTypeSelector(),
              const SizedBox(height: 16),
              const CartActionButtons(),
              const SizedBox(height: 16),
              const CartOrderInfoWidget(),
              const SizedBox(height: 20),
              const CartItemsList(),
            ],
          ),
        ),
      ),
    );
  }
}
