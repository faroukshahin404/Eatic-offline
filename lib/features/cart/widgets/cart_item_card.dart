import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../create_order/model/create_order_line_model.dart';
import '../cubit/cart_cubit.dart';
import 'cart_quantity_button.dart';

/// Single cart line: product name, modifiers, quantity controls, price.
class CartItemCard extends StatelessWidget {
  const CartItemCard({super.key, required this.line, required this.index});

  final CreateOrderLineModel line;
  final int index;

  @override
  Widget build(BuildContext context) {
    final modifiers = _modifiersText();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.greyE6E9EA,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.productName ?? 'Product',
                  style: AppFonts.styleBold14.copyWith(
                    color: AppColors.oppositeColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (modifiers.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    modifiers,
                    style: AppFonts.styleRegular12.copyWith(
                      color: AppColors.greyA4ACAD,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CartQuantityButton(
                icon: Icons.add,
                isFilled: true,
                onPressed:
                    () => context.read<CartCubit>().incrementQuantity(index),
              ),
              const SizedBox(width: 6),
              Text(
                '${line.quantity}',
                style: AppFonts.styleMedium14.copyWith(
                  color: AppColors.oppositeColor,
                ),
              ),
              const SizedBox(width: 6),
              CartQuantityButton(
                icon: Icons.remove,
                onPressed:
                    () => context.read<CartCubit>().decrementQuantity(index),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 78,
                child: Text(
                  '${line.lineTotal.toStringAsFixed(0)} ${'products.currency'.tr()}',
                  textAlign: TextAlign.end,
                  style: AppFonts.styleMedium14.copyWith(
                    color: AppColors.oppositeColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _modifiersText() {
    final parts = <String>[];
    if (line.variantLabel != null && line.variantLabel!.isNotEmpty) {
      parts.add(line.variantLabel!);
    }
    for (final o in line.selectedOptions) {
      parts.add(o.valueLabel);
    }
    return parts.join(' • ');
  }
}
