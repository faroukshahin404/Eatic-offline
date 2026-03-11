import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../model/create_order_variant_model.dart';

/// One selectable option row with radio and optional price modifier.
class VariantOptionTile extends StatelessWidget {
  const VariantOptionTile({
    super.key,
    required this.option,
    required this.selectedValueId,
    required this.onTap,
    this.priceModifier,
  });

  final CreateOrderVariableOption option;
  final int? selectedValueId;
  final VoidCallback onTap;
  final double? priceModifier;

  @override
  Widget build(BuildContext context) {
    final label = option.label;
    final modifierText = priceModifier != null && priceModifier! != 0
        ? ' (${priceModifier! > 0 ? '+' : ''}${priceModifier!.toInt()})'
        : '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Radio<int>(
                  value: option.valueId,
                  groupValue: selectedValueId,
                  onChanged: (_) => onTap(),
                  activeColor: AppColors.primary,
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary;
                    }
                    return AppColors.oppositeColor.withValues(alpha: 0.6);
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppFonts.styleRegular14.copyWith(
                      color: AppColors.oppositeColor,
                    ),
                    children: [
                      TextSpan(text: label),
                      if (modifierText.isNotEmpty)
                        TextSpan(
                          text: modifierText,
                          style: AppFonts.styleRegular14.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
