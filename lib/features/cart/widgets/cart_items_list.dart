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
  const CartItemsList({super.key, this.scrollable = false});

  final bool scrollable;

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
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${items.length}',
                    style: AppFonts.styleRegular12.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  context.tr('cart.order_list'),
                  style: AppFonts.styleBold14.copyWith(
                    color: AppColors.oppositeColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'cart.no_items'.tr(),
                    style: AppFonts.styleMedium14.copyWith(
                      color: AppColors.greyA4ACAD,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  shrinkWrap: !scrollable,
                  physics:
                      scrollable
                          ? const AlwaysScrollableScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    return CartItemCard(line: items[index], index: index);
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
