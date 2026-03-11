import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button_widget.dart';

/// Outlined-style button for choosing waiter. Placeholder onPressed.
class CartChooseWaiterButton extends StatelessWidget {
  const CartChooseWaiterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomButtonWidget(
        text: 'cart.choose_waiter'.tr(),
        onPressed: () {},
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
      ),
    );
  }
}
