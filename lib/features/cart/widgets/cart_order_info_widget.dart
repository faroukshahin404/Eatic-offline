import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import 'cart_order_info_row.dart';

/// Order info block: order number and table number from cart state.
class CartOrderInfoWidget extends StatelessWidget {
  const CartOrderInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.greyE6E9EA,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              CartOrderInfoRow(
                label: context.tr('cart.order_number'),
                value: state.orderNumber,
              ),
              const SizedBox(height: 12),
              CartOrderInfoRow(
                label: context.tr('cart.table_number'),
                value: state.tableNumber ?? '—',
                trailing: Icon(
                  Icons.table_restaurant,
                  color: AppColors.oppositeColor,
                  size: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
