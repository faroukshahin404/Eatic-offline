import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button_widget.dart';

/// Filled primary button for choosing table. Placeholder onPressed.
class CartChooseTableButton extends StatelessWidget {
  const CartChooseTableButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomButtonWidget(
        text: 'cart.choose_table'.tr(),
        onPressed: () {},
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
