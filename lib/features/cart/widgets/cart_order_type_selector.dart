import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/custom_padding.dart';
import '../../_main/cubit/main_cubit.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

/// Order type labels (static list): Hall, Takeaway, Delivery.
const List<String> _orderTypeKeys = [
  'cart.order_type_hall',
  'cart.order_type_takeaway',
  'cart.order_type_delivery',
];

/// Segmented control for order type: single selection, updates cart state on tap.
class CartOrderTypeSelector extends StatelessWidget {
  const CartOrderTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: BlocBuilder<CartCubit, CartState>(
        buildWhen: (p, c) =>
            p.selectedOrderTypeIndex != c.selectedOrderTypeIndex,
        builder: (context, state) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: List.generate(_orderTypeKeys.length, (index) {
                final isSelected = state.selectedOrderTypeIndex == index;
                return Expanded(
                  child: Material(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.greyE6E9EA,
                    child: InkWell(
                      onTap: () {
                        context.read<MainCubit>().setCurrentScreen();
                        context.read<CartCubit>().setOrderType(index);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          context.tr(_orderTypeKeys[index]),
                          textAlign: TextAlign.center,
                          style: AppFonts.styleMedium16.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.oppositeColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
