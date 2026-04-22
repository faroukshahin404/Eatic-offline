import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_button_widget.dart';

class CartFooterConfirmButton extends StatelessWidget {
  const CartFooterConfirmButton({super.key, this.onPressed, this.text});

  final VoidCallback? onPressed;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return CustomButtonWidget(
      text: text ?? 'cart.confirm_order'.tr(),
      onPressed: onPressed,
      width: double.infinity,
    );
  }
}
