import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

/// Read-only display of the current amount text for the custody amount dialog.
class CustodyAmountDisplay extends StatelessWidget {
  const CustodyAmountDisplay({super.key, required this.amountText});

  final String amountText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyE6E9EA),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      alignment: Alignment.centerRight,
      child: Text(
        amountText.isEmpty ? '' : amountText,
        style: AppFonts.styleRegular18.copyWith(color: AppColors.oppositeColor),
      ),
    );
  }
}
