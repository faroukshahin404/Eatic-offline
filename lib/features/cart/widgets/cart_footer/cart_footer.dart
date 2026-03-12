import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import 'cart_footer_confirm_button.dart';
import 'cart_footer_discount_section.dart';
import 'cart_footer_summary_row.dart';

class CartFooter extends StatelessWidget {
  const CartFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = 'products.currency'.tr();
    const totalBeforeTax = 850;
    const total = 930;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CartFooterSummaryRow(
            label: 'cart.total_before_discount'.tr(),
            value: '$totalBeforeTax $currency',
            style: AppFonts.styleMedium16.copyWith(
              color: AppColors.oppositeColor,
            ),
          ),
          const SizedBox(height: 5),
          const CartFooterDiscountSection(),
          const Divider(color: AppColors.greyE6E9EA, height: 30),
          CartFooterSummaryRow(
            label: 'cart.total'.tr(),
            value: '$total $currency',
            style: AppFonts.styleSemiBold16.copyWith(
              color: AppColors.oppositeColor,
            ),
          ),
          const SizedBox(height: 16),
          const CartFooterConfirmButton(),
        ],
      ),
    );
  }
}
