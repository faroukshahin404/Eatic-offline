import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_button_widget.dart';

class CartFooterConfirmButton extends StatelessWidget {
  const CartFooterConfirmButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CustomButtonWidget(
      text: 'cart.confirm_order'.tr(),
      onPressed: onPressed,
      width: double.infinity,
    );
  }
}
