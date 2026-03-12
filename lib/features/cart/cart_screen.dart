import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'widgets/cart_footer/cart_footer.dart';
import 'widgets/cart_header.dart';
import 'widgets/cart_order_type_selector.dart';
import 'widgets/cart_scrollable_content.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.greyE6E9EA),
        ),
        child: Column(
          spacing: 16,
          children: [
            const CartHeader(),
            const CartOrderTypeSelector(),
            const Expanded(child: CartScrollableContent()),
            const CartFooter(),
          ],
        ),
      ),
    );
  }
}
