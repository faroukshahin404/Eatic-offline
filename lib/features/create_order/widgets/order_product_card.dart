import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/create_order_cubit.dart';
import 'order_product_card_description.dart';
import 'order_product_card_header.dart';

/// Card showing product title, description, selected variant, addons total, and order line total.
/// Reads all data from [CreateOrderCubit] via context.
class OrderProductCard extends StatelessWidget {
  const OrderProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateOrderCubit>();

    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            OrderProductCardHeader(
              title: cubit.product?.name ?? '',
              total: cubit.orderLineTotal > 0 ? cubit.orderLineTotal : null,
            ),
            if (cubit.product?.description?.isNotEmpty == true)
              OrderProductCardDescription(
                description: cubit.product?.description ?? '',
              ),
          ],
        ),
      ),
    );
  }
}
