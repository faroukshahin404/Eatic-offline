import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button_widget.dart';
import '../cubit/cart_cubit.dart';

/// Filled primary button that clears the cart.
class CartAddNewOrderButton extends StatelessWidget {
  const CartAddNewOrderButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomButtonWidget(
      text: 'cart.add_new_order'.tr(),
      onPressed: () => context.read<CartCubit>().clearCart(),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    );
  }
}
