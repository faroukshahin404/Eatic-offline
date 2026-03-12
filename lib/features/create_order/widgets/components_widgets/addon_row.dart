import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../model/create_order_addon_model.dart';
import 'quantity_selector.dart';

/// Single addon row: checkbox, name + price modifier, quantity selector (-, count, +).
class AddonRow extends StatelessWidget {
  const AddonRow({
    super.key,
    required this.addon,
    required this.unitPrice,
    required this.quantity,
    required this.onCheckChanged,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CreateOrderAddonModel addon;
  final double unitPrice;
  final int quantity;
  final ValueChanged<bool> onCheckChanged;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final priceText = '(+${unitPrice.toInt()})';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyE6E9EA),
      ),
      child: Row(
        children: [
          Checkbox(
            value: quantity > 0,
            onChanged: (v) => onCheckChanged(v ?? false),
            activeColor: AppColors.primary,
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return Colors.transparent;
            }),
            checkColor: Colors.white,
            side: BorderSide(
              color: AppColors.oppositeColor.withValues(alpha: 0.5),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${addon.name} $priceText',
              style: AppFonts.styleRegular14.copyWith(
                color: AppColors.oppositeColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          QuantitySelector(
            quantity: quantity,
            onIncrement: onIncrement,
            onDecrement: onDecrement,
          ),
        ],
      ),
    );
  }
}
