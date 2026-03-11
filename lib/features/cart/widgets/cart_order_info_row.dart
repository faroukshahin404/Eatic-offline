import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

/// Single row: label and value (optional trailing widget).
class CartOrderInfoRow extends StatelessWidget {
  const CartOrderInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
  });

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style:
              AppFonts.styleMedium14.copyWith(color: AppColors.oppositeColor),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (trailing != null) ...[
                trailing!,
                const SizedBox(width: 8),
              ],
              Text(
                value,
                style: AppFonts.styleMedium14
                    .copyWith(color: AppColors.oppositeColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
