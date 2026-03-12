import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import 'circle_button.dart';

/// Quantity controls: minus button, number, plus button.
class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final canDecrement = quantity > 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleButton(
          icon: Icons.remove,
          onPressed: canDecrement ? onDecrement : null,
          isActive: canDecrement,
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 28,
          child: Text(
            '$quantity',
            style: AppFonts.styleBold14.copyWith(
              color: AppColors.oppositeColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 12),
        CircleButton(
          icon: Icons.add,
          onPressed: onIncrement,
          isActive: true,
        ),
      ],
    );
  }
}
