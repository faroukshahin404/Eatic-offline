import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Small circular +/- button for cart item quantity.
class CartQuantityButton extends StatelessWidget {
  const CartQuantityButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isFilled = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isFilled ? AppColors.primary : Colors.white,
      shape: const CircleBorder(side: BorderSide(color: AppColors.greyE6E9EA)),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 26,
          height: 26,
          child: Icon(
            icon,
            size: 14,
            color: isFilled ? Colors.white : AppColors.oppositeColor,
          ),
        ),
      ),
    );
  }
}
