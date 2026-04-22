import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../_main/cubit/main_cubit.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

/// Order type labels (static list): Hall, Takeaway, Delivery.

/// Segmented control for order type: single selection, updates cart state on tap.
class CartOrderTypeSelector extends StatelessWidget {
  const CartOrderTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: BlocBuilder<CartCubit, CartState>(
        buildWhen:
            (p, c) => p.selectedOrderTypeIndex != c.selectedOrderTypeIndex,
        builder: (context, state) {
          final orderTypes = state.orderTypes;
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: List.generate(orderTypes.length, (index) {
                final orderType = orderTypes[index];
                final isSelected = state.selectedOrderTypeIndex == orderType.id;
                return Expanded(
                  child: Material(
                    color:
                        isSelected ? AppColors.primary : AppColors.greyE6E9EA,
                    child: InkWell(
                      onTap: () {
                        context.read<MainCubit>().setCurrentScreen();
                        context.read<CartCubit>().setOrderType(orderType.id);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          context.tr(orderType.name),
                          textAlign: TextAlign.center,
                          style: AppFonts.styleMedium14.copyWith(
                            color:
                                isSelected
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
