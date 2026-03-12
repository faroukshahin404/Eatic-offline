import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import 'cart_item_card.dart';

/// Cart items section: header with count badge + list of cart item cards.
class CartItemsList extends StatelessWidget {
  const CartItemsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      buildWhen: (p, c) => p.items != c.items,
      builder: (context, state) {
        final items = state.items;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${items.length}',
                    style: AppFonts.styleMedium14.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr('cart.order_list'),
                  style: AppFonts.styleBold16.copyWith(color: AppColors.oppositeColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'cart.no_items'.tr(),
                  style: AppFonts.styleMedium14.copyWith(color: AppColors.greyA4ACAD),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return CartItemCard(line: items[index], index: index);
                },
              ),
          ],
        );
      },
    );
  }
}
