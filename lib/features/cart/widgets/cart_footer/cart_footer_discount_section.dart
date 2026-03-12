import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/widgets/custom_text.dart';

class CartFooterDiscountSection extends StatelessWidget {
  const CartFooterDiscountSection({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          text: 'cart.add_discount'.tr(),
          style: AppFonts.styleMedium16.copyWith(color: AppColors.oppositeColor),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.fillColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.greyE6E9EA),
            ),
            child: Text(
              'cart.discount_type'.tr(),
              style: AppFonts.styleMedium14.copyWith(color: AppColors.greyA4ACAD),
            ),
          ),
        ),
      ],
    );
  }
}
