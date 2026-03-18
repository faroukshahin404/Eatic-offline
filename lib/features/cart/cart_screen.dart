import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import 'cubit/cart_cubit.dart';
import 'widgets/cart_footer/_cart_footer.dart';
import 'widgets/cart_header.dart';
import 'widgets/cart_order_type_selector.dart';
import 'widgets/cart_scrollable_content.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartCubit>()
      ..refreshHasOpenCustody()
      ..loadPaymentMethods();
  }

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
