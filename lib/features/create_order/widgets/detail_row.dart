import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

/// A row showing a label on the left and value on the right.
class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppFonts.styleRegular14.copyWith(color: AppColors.oppositeColor),
        ),
        Text(
          value,
          style: AppFonts.styleBold14.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }
}
