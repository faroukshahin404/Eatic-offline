import 'package:flutter/material.dart';

import 'dart:ui' as ui;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';

/// A row showing a label and value (e.g. "Selected variant" / "Large - 25.0").
class OrderProductSummaryRow extends StatelessWidget {
  const OrderProductSummaryRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textDirection: ui.TextDirection.rtl,
        children: [
          Text(
            value,
            style: AppFonts.styleMedium14.copyWith(
              color: AppColors.oppositeColor,
            ),
          ),
          Text(
            label,
            style: AppFonts.styleMedium14.copyWith(
              color: AppColors.oppositeColor,
            ),
          ),
        ],
      ),
    );
  }
}
